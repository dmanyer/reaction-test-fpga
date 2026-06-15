// 16位最大长度 LFSR，产生伪随机数，映射到 500~5000 ms 等待时间
// 反馈多项式：x^16 + x^14 + x^13 + x^11 + 1
// 最大序列长度：65535（不含全零状态）
// 输出 wait_val：当前等待时长（ms，范围 500~5000）

module lfsr (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick,      // 1ms 节拍，每 tick 移位一次（持续随机化）
    input  wire        sample,    // 上升沿时锁存当前 lfsr 值作为本次等待时长
    output reg  [12:0] wait_val   // 锁存的等待时长，ms（13位可表示0~8191）
);

reg [15:0] lfsr_reg;

// 反馈位：16,14,13,11（对应索引15,13,12,10）
wire feedback = lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10];

// LFSR 移位：每个tick推进一步
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr_reg <= 16'hACE1;  // 非零初始种子
    end else if (tick) begin
        lfsr_reg <= {lfsr_reg[14:0], feedback};  // 左移，feedback 填入最低位
    end
end

// 直接取 lfsr_reg 低12位，范围0~4095，加500后范围500~4595
wire [12:0] mapped = {1'b0, lfsr_reg[11:0]};

// 状态机拉高 sample 时记录本次等待时长
reg sample_prev;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sample_prev <= 0;
        wait_val    <= 13'd2000;
    end else begin
        sample_prev <= sample;
        if (sample && !sample_prev)
            wait_val <= mapped + 13'd500;
            // mapped 是纯连线，加法只有一级，路径极短
    end
end

endmodule