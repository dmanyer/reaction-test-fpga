// btn_out 去抖后的稳定电平（与输入同极性）
// btn_pulse 按键按下瞬间的单周期高脉冲（上升沿检测）

module debounce #(
    parameter STABLE_COUNT = 20  // 需要保持稳定的 tick 数
)(
    input  wire clk,      // 系统时钟
    input  wire rst_n,    // 低电平复位
    input  wire tick,     // 来自 clk_div 的 1ms 使能脉冲
    input  wire btn_in,   // 原始按键输入（按下为高电平，未按为低电平）
    output reg  btn_out,  // 去抖后稳定输出
    output wire btn_pulse // 按下瞬间单周期脉冲（用于触发状态机）
);

localparam CNT_WIDTH = $clog2(STABLE_COUNT + 1);

reg [CNT_WIDTH-1:0] cnt;
reg btn_sync0, btn_sync1;  // 两级同步寄存器，消除亚稳态

// ---- 1.两级同步，消除异步输入的亚稳态风险 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        btn_sync0 <= 0;
        btn_sync1 <= 0;
    end else begin
        btn_sync0 <= btn_in;
        btn_sync1 <= btn_sync0;
    end
end

// ---- 2.稳定计数 ----
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt     <= 0;
        btn_out <= 0;
    end else if (tick) begin
        if (btn_sync1 == btn_out) begin
            // 输入与当前输出一致，稳定，计数器清零
            cnt <= 0;
        end else begin
            if (cnt == STABLE_COUNT - 1) begin
                // 已稳定足够长时间：确认变化，更新输出
                btn_out <= btn_sync1;
                cnt     <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
end

// ---- 3.边沿检测，产生单周期按下脉冲 ----
reg btn_out_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) btn_out_prev <= 0;
    else        btn_out_prev <= btn_out;
end

// 上升沿：btn_out 从 0 变 1，即按键刚被确认按下
assign btn_pulse = btn_out & ~btn_out_prev;

endmodule