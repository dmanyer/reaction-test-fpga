module result_calc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        result_valid,
    input  wire [12:0] result_val,
    output reg  [12:0] avg_val
);


reg [12:0] hist[2:0];   // 保存最近三次有效反应时间
reg [1:0] count;        // 当前已有有效记录数：0,1,2,3
reg [14:0] sum3_pipe;   // 三次求和流水寄存器
reg [30:0] div3_prod;   // 常数乘法流水寄存器

// 流水线有效标志
reg div3_stage1_valid;
reg div3_stage2_valid;

// 显式扩展，避免 13-bit 加法中间溢出
wire [14:0] result_ext = {2'b00, result_val};
wire [14:0] hist0_ext  = {2'b00, hist[0]};
wire [14:0] hist1_ext  = {2'b00, hist[1]};

reg [14:0] next_sum;    // 根据当前 count 计算加入本次结果后的 sum

always @(*) begin
    case (count)
        2'd0: begin
            next_sum = result_ext;  // 第一次：只有 result_val
        end
        2'd1: begin
            next_sum = hist0_ext + result_ext;  // 第二次：hist[0] + result_val
        end
        default: begin 
            next_sum = hist1_ext + hist0_ext + result_ext;  // 第三次及以后：最近两次+本次, hist[0] = 上一次, hist[1] = 上上次
        end
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hist[0] <= 13'd0;
        hist[1] <= 13'd0;
        hist[2] <= 13'd0;

        count <= 2'd0;

        avg_val <= 13'd0;

        sum3_pipe <= 15'd0;
        div3_prod <= 31'd0;

        div3_stage1_valid <= 1'b0;
        div3_stage2_valid <= 1'b0;
    end else begin
        // 默认推进流水线 valid
        div3_stage2_valid <= div3_stage1_valid;
        div3_stage1_valid <= 1'b0;

        // 第二级：常数乘法(对 0~15000，(x * 21846) >> 16 等价于 floor(x / 3)
        if (div3_stage1_valid) begin
            div3_prod <= sum3_pipe * 16'd21846;
        end

        // 第三级：取高位作为除以3结果
        if (div3_stage2_valid) begin
            avg_val <= div3_prod[30:16];
        end

        // 新结果到
        if (result_valid) begin
            // 更新历史记录：hist[0] 永远是最近一次
            hist[2] <= hist[1];
            hist[1] <= hist[0];
            hist[0] <= result_val;

            // 更新有效记录数，最多保持为3
            if (count < 2'd3)
                count <= count + 1'b1;
            else
                count <= 2'd3;

            // 根据已有记录数计算平均值
            case (count)
                2'd0: begin// 第一次
                    avg_val <= result_val;
                end
                2'd1: begin// 第二次：右移/2 
                    avg_val <= (hist0_ext + result_ext) >> 1;
                end
                default: begin// 第三次及以后：先寄存三次和，下一拍做常数乘法
                    sum3_pipe <= next_sum;
                    div3_stage1_valid <= 1'b1;
                end
            endcase
        end
    end
end

endmodule