// 主状态机：协调所有子模块，实现完整测试流程
// 1.状态寄存器（时序）
// 2.次态逻辑（组合）
// 3.输出逻辑（组合）

module fsm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start_pulse,   // START 按键去抖后的单周期脉冲
    input  wire        react_pulse,   // 反应按键去抖后的单周期脉冲
    input  wire        tick,          // 1ms 基准脉冲
    input  wire [12:0] wait_val,      // LFSR 锁存的随机等待时长 ms
    input  wire [12:0] react_time,    // timer 的当前计时值 ms
    input  wire        timeout,       // timer 超时信号 react_time >= 5000
    input  wire [12:0] avg_val,       // 来自 result_calc 三次均值

    // 控制输出：驱动各子模块
    output reg         lfsr_sample,   // 拉高一个周期以锁存新随机数
    output reg         timer_start,   // 高电平 timer 计数
    output reg         timer_clear,   // 高电平 timer 清零

    // 显示控制：数码管驱动显示
    output reg  [2:0]  disp_mode,     // 0 "----", 1 "||||", 2 数值, 3 "FAIL"
    output reg  [12:0] disp_val,      // 要显示的数值 ms

    // 统计输出：结果计算模块
    output reg         result_valid,  // 本次结果有效，存入历史
    output reg  [12:0] result_val     // 本次有效反应时间
);

// ---- 状态编码 ----
localparam IDLE  = 3'd0;
localparam WAIT  = 3'd1;
localparam REACT = 3'd2;
localparam SHOW  = 3'd3;
localparam AVG   = 3'd4;
localparam FAIL  = 3'd5;

// ---- 状态寄存器 ----
reg [2:0] state_prev, state, next_state;

// ---- 等待计数器： WAIT 状态倒计时 ----
reg [12:0] wait_cnt;

// ---- Fail：反应时间 < 100ms or >=5000ms ----
wire is_fail = (react_time < 13'd100) || timeout;

// 1/状态寄存器（时序逻辑）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state_prev <= IDLE;
    else        state_prev <= state;
end
wire state_entry = (state != state_prev);  // 本拍刚发生跳转

// 2/次态逻辑（纯组合逻辑）
always @(*) begin
    next_state = state;  // default
    case (state)

        IDLE: begin
            if (start_pulse) next_state = WAIT;
        end

        WAIT: begin
            // 提前按，判 Fail
            if (react_pulse)              next_state = FAIL;
            // 等待计数器归零，反应阶段
            else if (wait_cnt == 13'd0)   next_state = REACT;
        end

        REACT: begin
            if (react_pulse) next_state = SHOW;  // 正常按键
            else if (timeout) next_state = SHOW; // 超时也进SHOW，SHOW里判Fail
        end

        SHOW: begin
            if (start_pulse) next_state = AVG;
        end

        AVG: begin
            if (start_pulse) next_state = IDLE;
        end

        FAIL: begin
            if (start_pulse) next_state = IDLE;
        end

        default: next_state = IDLE;
    endcase
end

// 3/输出逻辑 + 内部寄存器更新（时序）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr_sample  <= 0;
        timer_start  <= 0;
        timer_clear  <= 0;
        disp_mode    <= 0;    // 显示 ----
        disp_val     <= 0;
        result_valid <= 0;
        result_val   <= 0;
        wait_cnt     <= 13'd2000;
        
    end else begin
        lfsr_sample  <= 0;
        timer_clear  <= 0;
        result_valid <= 0;

        case (state)
            IDLE: begin
                disp_mode   <= 3'd0;
                timer_start <= 0;
                if (start_pulse) begin
                    lfsr_sample <= 1;
                    timer_clear <= 1;
                end
            end

            WAIT: begin
                disp_mode   <= 3'd0;
                timer_start <= 0;
                // 刚进入 WAIT 时初始化倒计时
                if (state_entry) wait_cnt <= wait_val;
                else if (tick && wait_cnt > 0) wait_cnt <= wait_cnt - 1;
            end

            REACT: begin
                disp_mode   <= 3'd1;   // 持续显示 ||||
                timer_start <= 1;
                // REACT 里不再修改 disp_mode，跳转后由 SHOW/FAIL 接管
            end

            SHOW: begin
                timer_start <= 0;
                // 刚进入 SHOW 时根据结果设置显示内容
                if (state_entry) begin
                    if (is_fail) begin
                        disp_mode <= 3'd3;
                    end else begin
                        disp_mode    <= 3'd2;
                        disp_val     <= react_time;
                        result_valid <= 1;
                        result_val   <= react_time;
                    end
                end
            end

            AVG: begin
                timer_start <= 0;
                if (state_entry) begin
                    disp_mode <= 3'd2;
                    disp_val  <= avg_val;
                end
            end

            FAIL: begin
                timer_start <= 0;
                timer_clear <= 1;
                disp_mode   <= 3'd3;
            end
        endcase

        if (state == IDLE && next_state == WAIT)
            wait_cnt <= wait_val;
    end
end

endmodule