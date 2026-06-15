module clk_div #(
    parameter DIVIDER = 125000  // 125MHz / 125000 = 1kHz → 1ms tick
                                // 仿真时可改为较小值加速仿真
)(
    input  wire clk,    // 系统时钟输入
    input  wire rst_n,  // active-low
    output reg  tick    // 每 1ms 输出一个单周期高电平脉冲
);

localparam CNT_WIDTH = $clog2(DIVIDER); // counter bit width

reg [CNT_WIDTH-1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位：清空计数器和输出
        cnt  <= 0;
        tick <= 0;
    end else begin
        if (cnt == DIVIDER - 1) begin
            cnt  <= 0;
            tick <= 1;  // 脉冲：这个周期输出高电平
        end else begin
            cnt  <= cnt + 1;
            tick <= 0;  // 其余时间保持低电平
        end
    end
end

endmodule