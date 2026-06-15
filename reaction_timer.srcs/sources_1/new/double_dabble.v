// 将 13 位二进制数转换为 4 位 BCD（千、百、十、个）
// 算法：移位+加3，13次迭代，用组合逻辑展开

module double_dabble (
    input  wire [12:0] bin,
    output wire [3:0]  thousands,
    output wire [3:0]  hundreds,
    output wire [3:0]  tens,
    output wire [3:0]  ones
);

reg [28:0] shift [13:0];  // 14级流水（13次移位+初始）
integer i;

// 展开为纯组合逻辑
always @(*) begin
    // 初始：BCD部分全0，二进制填入低位
    shift[0] = {16'b0, bin};

    for (i = 0; i < 13; i = i + 1) begin
        // 检查每个BCD位，≥5则加3
        shift[i+1][28:0] = shift[i][28:0];

        // 千位 [27:24]
        if (shift[i][27:24] >= 4'd5)
            shift[i+1][27:24] = shift[i][27:24] + 4'd3;

        // 百位 [23:20]
        if (shift[i][23:20] >= 4'd5)
            shift[i+1][23:20] = shift[i][23:20] + 4'd3;

        // 十位 [19:16]
        if (shift[i][19:16] >= 4'd5)
            shift[i+1][19:16] = shift[i][19:16] + 4'd3;

        // 个位 [15:12]
        if (shift[i][15:12] >= 4'd5)
            shift[i+1][15:12] = shift[i][15:12] + 4'd3;

        // 左移一位
        shift[i+1] = shift[i+1] << 1;
        shift[i+1][0] = shift[i][28-i]; // 移入二进制的下一位
    end
end

assign thousands = shift[13][27:24];
assign hundreds  = shift[13][23:20];
assign tens      = shift[13][19:16];
assign ones      = shift[13][15:12];

endmodule