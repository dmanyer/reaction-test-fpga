// 仿真参数：clk_div DIVIDER=10，debounce STABLE_COUNT=4，加速仿真

`timescale 1ns/1ps

module tb_top;

reg  clk, rst_n, btn_start, btn_react;
wire [6:0] seg;
wire [3:0] an;
wire [3:0] led;

// 例化顶层（覆盖参数加速仿真）
top #(
    .CLK_DIVIDER    (10),   // 10个时钟周期出一个tick，大幅加速
    .DEBOUNCE_COUNT (4)     // 4ms去抖
) u_top (
    .clk       (clk),
    .rst_n     (rst_n),
    .btn_start (btn_start),
    .btn_react (btn_react),
    .seg       (seg),
    .an        (an),
    .led       (led)
);

initial clk = 0;
always #5 clk = ~clk;

// 模拟干净消抖按键脉冲
task press_start;
    integer i;
    begin
        btn_start = 1;
        repeat(60) @(posedge clk);  // 保持60个clk，覆盖去抖窗口
        btn_start = 0;
        repeat(10) @(posedge clk);
    end
endtask

task press_react;
    begin
        btn_react = 1;
        repeat(60) @(posedge clk);
        btn_react = 0;
        repeat(10) @(posedge clk);
    end
endtask

initial begin
    rst_n=0; btn_start=0; btn_react=0;
    #30; rst_n=1;
    repeat(20) @(posedge clk);

    $display("=== Top-level integration simulation begins ===");

    press_start;
    repeat(50) @(posedge clk);
    $display("After pressing START: disp_mode expected 0(----)");

    // DIVIDER=10, wait_val最小500，需至少500个tick=5000个clk
    // 多等确保WAIT倒计时结束
    repeat(8000) @(posedge clk);
    $display("Wait for the countdown to end, then enter REACTs");

    press_react;
    repeat(20) @(posedge clk);   // 等输出稳定
    $display("SHOW: seg=%b an=%b", seg, an);

    press_start;
    repeat(20) @(posedge clk);
    $display("AVG: seg=%b an=%b", seg, an);

    press_start;
    repeat(20) @(posedge clk);
    $display("Return to IDLE: seg=%b an=%b", seg, an);

    $display("Top-level integration simulation completed!");
    $finish;
end

endmodule