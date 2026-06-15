// 1. LFSR 输出的 wait_val 每次 sample 后落在 500~5000 范围内
// 2. 连续多次 sample 值不完全相同验证伪随机性
// 3. timer 在 start 期间每 tick 递增一次
// 4. timer 在 clear 后归零
// 5. timer 在 count==5000 时置高 timeout 并停止递增

`timescale 1ns/1ps

module tb_lfsr_timer;

reg        clk, rst_n, tick;
reg        sample, t_start, t_clear;
wire [12:0] wait_val, count;
wire        timeout;

lfsr uut_lfsr (
    .clk      (clk),
    .rst_n    (rst_n),
    .tick     (tick),
    .sample   (sample),
    .wait_val (wait_val)
);

timer uut_timer (
    .clk     (clk),
    .rst_n   (rst_n),
    .tick    (tick),
    .start   (t_start),
    .clear   (t_clear),
    .count   (count),
    .timeout (timeout)
);

initial clk = 0;
always #5 clk = ~clk;

// tick 产生任务
task do_tick;
    begin
        @(posedge clk); tick = 1;
        @(posedge clk); tick = 0;
    end
endtask

// 产生 N 个 tick
task run_ticks;
    input integer n;
    integer i;
    begin
        for (i = 0; i < n; i = i+1) do_tick;
    end
endtask

integer i;
initial begin
    clk=0; rst_n=0; tick=0; sample=0;
    t_start=0; t_clear=0;
    #30; rst_n=1; #20;

    $display("=== 1/ LFSR Randomness Verification ===");
    run_ticks(8); // LFSR 充分移位

    // 连续 sample 5 次，观察 wait_val
    for (i = 0; i < 5; i = i+1) begin
        run_ticks(3); // 模拟随机时刻采样
        
        // 产生 sample 脉冲
        @(posedge clk); sample = 1;
        @(posedge clk); sample = 0;
        #20;
        $display("  sample[%0d]: wait_val = %0d ms (valid: %s)",
            i, wait_val,
            (wait_val >= 500 && wait_val <= 5000) ? "YES" : "NO");
    end

    $display("=== 2/ Timer Time Verification ===");

    // 清零
    @(posedge clk); t_clear = 1;
    @(posedge clk); t_clear = 0;
    $display("  after clear: count = %0d (should be 0)", count);

    // 计时 10 tick
    t_start = 1;
    run_ticks(10);
    t_start = 0;
    $display("  after 10 ticks: count = %0d (should be 10)", count);

    // 停止后再跑几个 tick，count 不应再变
    run_ticks(3);
    $display("  after 3 more ticks (start=0): count = %0d (should still be 10)", count);

    // 清零重新开始
    @(posedge clk); t_clear = 1;
    @(posedge clk); t_clear = 0;
    $display("  after second clear: count = %0d (should be 0)", count);

    $display("=== 3/ Timer Timeout Verification ===");
    t_start = 1;
    run_ticks(5002);   // 超过 5000
    t_start = 0;
    $display("  count = %0d, timeout = %b (count should be 5000, timeout should be 1)",
             count, timeout);

    #50;
    $display("All tests done.");
    $finish;
end

// 实时监视 timeout
always @(posedge timeout)
    $display("[%0t ns] *** timeout asserted! count = %0d ***", $time, count);

endmodule