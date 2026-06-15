// 反应时间计时器，1ms 分辨率，最大计数 5000ms
// - start 高电平时开始计数（每 tick 加1）
// - start 变低时停止计数，保持当前值
// - clear 高电平时异步清零（为下次测试做准备）
// - timeout 在计数达到 MAX_TIME 时拉高，通知状态机超时

module timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick,      // 1ms 使能脉冲
    input  wire        start,     // 高电平计数
    input  wire        clear,     // 高电平清零
    output reg  [12:0] count,     // 当前计时值, ms（0~5000）
    output wire        timeout    // 计时到 MAX_TIME 拉高
);

localparam MAX_TIME = 13'd5000;

assign timeout = (count >= MAX_TIME);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
    end else if (clear) begin
        count <= 0;
    end else if (start && tick && !timeout) begin
        // 仅在计时使能、tick到来、未超时时递增
        count <= count + 1;
    end
end

endmodule