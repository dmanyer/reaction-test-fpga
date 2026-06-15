`timescale 1ns/1ps   // 时间单位 1ns，精度 1ps

module tb_clk_div;

reg  clk;
reg  rst_n;
wire tick;

// 真实板上 DIVIDER=125000，这里用 10 方便观察
clk_div #(.DIVIDER(10)) uut (
    .clk   (clk),
    .rst_n (rst_n),
    .tick  (tick)
);

// ---- 产生时钟 ----
initial clk = 0;
always #5 clk = ~clk;  // 5ns 翻转一次，周期 10ns = 100MHz

// ---- 激励序列 ----
initial begin
    rst_n = 0;
    #25;           // 保持复位 25ns（覆盖 2~3 个时钟周期）
    rst_n = 1;     // 释放复位，电路开始工作

    #600; // 观察至少 5 个 tick 脉冲

    $display("Simulation finished.");
    $finish;
end

// ---- 自动检查：打印每次 tick 出现的时间 ----
always @(posedge tick) begin
    $display("[%0t ns] tick pulse detected", $time);
end

endmodule