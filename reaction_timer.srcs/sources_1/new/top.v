// 顶层模块：连接所有子模块，完整实现
module top #(
    parameter CLK_DIVIDER    = 125000,  // 仿真时从外部覆盖为小值
    parameter DEBOUNCE_COUNT = 20
)(
    input  wire       clk,        // 125MHz 系统时钟（PYNQ-Z2）
    input  wire       rst_n,      // 复位按键（低有效）
    input  wire       btn_start,  // START 按键（高有效）
    input  wire       btn_react,  // 反应按键（高有效）
    output wire [6:0] seg,        // 7段段选
    output wire [3:0] an,         // 7段位选
    output wire dp,               // 小数点
    output wire [3:0] led         // 状态指示 LED（预留）
);

// 例化时使用参数
clk_div #(
    .DIVIDER(CLK_DIVIDER)
) u_clk_div (
    .clk   (clk),
    .rst_n (rst_n),
    .tick  (tick)
);

debounce #(
    .STABLE_COUNT(DEBOUNCE_COUNT)
) u_deb_start (
    .clk       (clk),
    .rst_n     (rst_n),
    .tick      (tick),
    .btn_in    (btn_start),
    .btn_out   (start_out),
    .btn_pulse (start_pulse)
);

debounce #(
    .STABLE_COUNT(DEBOUNCE_COUNT)
) u_deb_react (
    .clk       (clk),
    .rst_n     (rst_n),
    .tick      (tick),
    .btn_in    (btn_react),
    .btn_out   (react_out),
    .btn_pulse (react_pulse)
);

// ---- 内部连线 ----
wire tick;
wire start_out, start_pulse;
wire react_out, react_pulse;
wire lfsr_sample;
wire timer_start, timer_clear;
wire [12:0] wait_val, react_time, avg_val;
wire timeout;
wire [2:0] disp_mode;
wire [12:0] disp_val_fsm;
wire result_valid;
wire [12:0] result_val;

// disp_val 在 AVG 状态显示 avg_val，其余状态显示 fsm 的 disp_val
// 简化处理：顶层直接将 avg_val 接回 FSM 的显示值输入
wire [12:0] disp_val = (disp_mode == 3'd2 && /* AVG状态由fsm内部判断 */ 1'b0)
                       ? avg_val : disp_val_fsm;
                       
wire [6:0] seg_internal;
wire [3:0] an_internal;

// ---- 模块例化 ----
lfsr u_lfsr (
    .clk      (clk),
    .rst_n    (rst_n),
    .tick     (tick),
    .sample   (lfsr_sample),
    .wait_val (wait_val)
);

timer u_timer (
    .clk     (clk),
    .rst_n   (rst_n),
    .tick    (tick),
    .start   (timer_start),
    .clear   (timer_clear),
    .count   (react_time),
    .timeout (timeout)
);

fsm u_fsm (
    .clk         (clk),
    .rst_n       (rst_n),
    .start_pulse (start_pulse),
    .react_pulse (react_pulse),
    .tick        (tick),
    .wait_val    (wait_val),
    .react_time  (react_time),
    .timeout     (timeout),
    .avg_val     (avg_val),       // 接入均值供 AVG 状态显示
    .lfsr_sample (lfsr_sample),
    .timer_start (timer_start),
    .timer_clear (timer_clear),
    .disp_mode   (disp_mode),
    .disp_val    (disp_val_fsm),
    .result_valid(result_valid),
    .result_val  (result_val)
);

result_calc u_calc (
    .clk          (clk),
    .rst_n        (rst_n),
    .result_valid (result_valid),
    .result_val   (result_val),
    .avg_val      (avg_val)
);

seg7_driver u_seg7 (
    .clk       (clk),
    .rst_n     (rst_n),
    .tick      (tick),
    .disp_mode (disp_mode),
    .disp_val  (disp_val_fsm),
    .seg       (seg_internal),
    .an        (an_internal)
);

// LED 辅助调试
assign led[0] = rst_n;
assign led[1] = btn_start;
assign led[2] = btn_react;
assign led[3] = tick;

assign seg = seg_internal;
assign an  = an_internal;
assign dp = 1'b1; // 共阳极：DP 低亮，高灭

endmodule