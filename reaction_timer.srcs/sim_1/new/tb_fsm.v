// 路径1：IDLE-WAIT-REACT-SHOW-AVG-IDLE（正常流程）
// 路径2：WAIT 期间提前按键-FAIL-IDLE
// 路径3：REACT 超时-SHOW(FaiL)-AVG-IDLE

`timescale 1ns/1ps

module tb_fsm;

reg        clk, rst_n, tick;
reg        start_pulse, react_pulse;
reg [12:0] wait_val, react_time_r;
reg        timeout_r;
wire       lfsr_sample, timer_start, timer_clear;
wire [2:0] disp_mode;
wire [12:0] disp_val;
wire       result_valid;
wire [12:0] result_val;

// 寄存器模拟 timer 输出方便手动控制仿真，实际顶层连接真实 timer 模块

fsm uut (
    .clk         (clk),
    .rst_n       (rst_n),
    .start_pulse (start_pulse),
    .react_pulse (react_pulse),
    .tick        (tick),
    .wait_val    (wait_val),
    .react_time  (react_time_r),
    .timeout     (timeout_r),
    .lfsr_sample (lfsr_sample),
    .timer_start (timer_start),
    .timer_clear (timer_clear),
    .disp_mode   (disp_mode),
    .disp_val    (disp_val),
    .result_valid(result_valid),
    .result_val  (result_val)
);

initial clk = 0;
always #5 clk = ~clk;

task do_tick;
    begin @(negedge clk); tick=1; @(negedge clk); tick=0; end
endtask

task pulse_start;
    begin @(negedge clk); start_pulse=1; @(negedge clk); start_pulse=0; end
endtask

task pulse_react;
    begin @(negedge clk); react_pulse=1; @(negedge clk); react_pulse=0; end
endtask

// 模拟 WAIT 状态倒计时结束（设 wait_val 为小值）
task wait_expire;
    integer i;
    begin
        for (i=0; i<5; i=i+1) do_tick;  // 走完几个tick让wait_cnt归零
    end
endtask

initial begin
    clk=0; rst_n=0; tick=0;
    start_pulse=0; react_pulse=0;
    wait_val=13'd3; react_time_r=0; timeout_r=0;
    #30; rst_n=1; #20;

    $display("=== 1/ Normal process ===");
    $display("[IDLE] disp_mode=%0d", disp_mode);

    pulse_start; #20;
    $display("[WAIT] disp_mode=%0d (expect 0=----)", disp_mode);

    // 等待 wait_cnt 归零（wait_val=3，3 tick）
    do_tick; do_tick; do_tick; do_tick; #20;
    $display("[REACT] disp_mode=%0d (expect 1=||||)", disp_mode);
    
    react_time_r = 13'd250; // 模拟 250ms 后按下反应键
    pulse_react; repeat(4) @(posedge clk); #20;
    $display("[SHOW] disp_mode=%0d disp_val=%0d (expect 2, 250)",
             disp_mode, disp_val);

    pulse_start; #20;
    $display("[AVG] disp_mode=%0d", disp_mode);

    pulse_start; #20;
    $display("[IDLE] disp_mode=%0d (expect 0)", disp_mode);

    $display("\n==== 2/ Press the key in advance during WAIT ====");
    pulse_start; #20;
    $display("[WAIT]");
    pulse_react; #20;   // 在 WAIT 里按反应键
    $display("[FAIL] disp_mode=%0d (expect 3=FaiL)", disp_mode);
    pulse_start; #20;
    $display("[IDLE] disp_mode=%0d", disp_mode);

    $display("\n==== 3/ REACT Timeout ====");
    pulse_start; #20;
    do_tick; do_tick; do_tick; do_tick; #20;
    $display("[REACT]");
    react_time_r = 13'd5000; timeout_r = 1; #20;
    $display("[SHOW](Fail): disp_mode=%0d (expect 3=FaiL)", disp_mode);
    timeout_r = 0;
    pulse_start; #20;
    pulse_start; #20;
    $display("[IDLE]");

    #50;
    $display("All FSM paths verified.");
    $finish;
end

// 状态监视
always @(posedge clk)
    if (result_valid)
        $display("[%0t ns] result_valid! val=%0d ms", $time, result_val);

endmodule