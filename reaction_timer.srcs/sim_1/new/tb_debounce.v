`timescale 1ns/1ps

module tb_debounce;

reg  clk, rst_n, tick, btn_in;
wire btn_out, btn_pulse;

// 例化：缩小 STABLE_COUNT 加速仿真
debounce #(.STABLE_COUNT(4)) uut (
    .clk       (clk),
    .rst_n     (rst_n),
    .tick      (tick),
    .btn_in    (btn_in),
    .btn_out   (btn_out),
    .btn_pulse (btn_pulse)
);

// 时钟周期 10ns
initial clk = 0;
always #5 clk = ~clk;

// 每次调用模拟一个 1ms tick
task do_tick;
    begin
        @(posedge clk);
        tick = 1;
        @(posedge clk);
        tick = 0;
    end
endtask

// 主激励
integer i;
initial begin
    rst_n  = 0; btn_in = 0; tick = 0; //initialize
    #30;
    rst_n = 1;
    #20;

    $display("=== 1/ Normal press (stable after shaking)===");
    btn_in = 1; do_tick;   // tick 1：高
    btn_in = 0; do_tick;   // tick 2：抖动回低
    btn_in = 1; do_tick;   // tick 3：抖动回高
    btn_in = 1; do_tick;   // tick 4：稳定高（第1个稳定tick）
    btn_in = 1; do_tick;   // tick 5：第2个
    btn_in = 1; do_tick;   // tick 6：第3个
    btn_in = 1; do_tick;   // tick 7：第4个，达到 STABLE_COUNT
    #50;
    $display("btn_out=%b btn_pulse should have fired", btn_out);

    // 保持按下状态再等几个 tick
    repeat(3) do_tick;

    $display("=== 2/ Release key ===");
    btn_in = 0;
    repeat(5) do_tick;
    #50;
    $display("btn_out=%b (should be 0)", btn_out);

    $display("=== 3/ Short jitter (should be filtered)===");
    btn_in = 1; do_tick;
    btn_in = 1; do_tick;
    btn_in = 0; do_tick;   // 只持续2个tick，被过滤
    #50;
    $display("btn_out=%b (should be 0, glitch filtered)", btn_out);

    #100;
    $display("Simulation done.");
    $finish;
end

// 监视 btn_pulse
always @(posedge btn_pulse)
    $display("[%0t ns] *** btn_pulse fired! btn_out=%b ***", $time, btn_out);

endmodule