// 端口说明（共阳极数码管，低电平点亮段）：
module seg7_driver (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick,        // 1ms 基准，用于扫描分频
    input  wire [2:0]  disp_mode,
    input  wire [12:0] disp_val,    // 要显示的数值（0~5000）
    output reg  [6:0]  seg,         // 段选（低有效）
    output reg  [3:0]  an           // 位选（低有效）
);

// ---- 扫描计数器 ----
localparam integer SCAN_DIV = 31250;

reg [15:0] scan_div_cnt;
reg [1:0]  scan_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scan_div_cnt <= 16'd0;
        scan_cnt     <= 2'd0;
    end else begin
        if (scan_div_cnt == SCAN_DIV - 1) begin
            scan_div_cnt <= 16'd0;
            scan_cnt     <= scan_cnt + 1'b1;
        end else begin
            scan_div_cnt <= scan_div_cnt + 1'b1;
        end
    end
end

wire [3:0] digit_th, digit_h, digit_t, digit_u;
double_dabble u_bcd (
    .bin       (disp_val),
    .thousands (digit_th),
    .hundreds  (digit_h),
    .tens      (digit_t),
    .ones      (digit_u)
);

// ---- 段码查找表----
function [6:0] bcd_to_seg; // 低有效（共阳极，0=亮）
    input [3:0] bcd;
    case (bcd)
        4'd0: bcd_to_seg = 7'b1000000;  // 0: a~f亮, g灭        
        4'd1: bcd_to_seg = 7'b1111001;  // 1: b,c亮        
        4'd2: bcd_to_seg = 7'b0100100;  // 2: a,b,d,e,g亮       
        4'd3: bcd_to_seg = 7'b0110000;  // 3: a,b,c,d,g亮        
        4'd4: bcd_to_seg = 7'b0011001;  // 4: b,c,f,g亮        
        4'd5: bcd_to_seg = 7'b0010010;  // 5: a,c,d,f,g亮        
        4'd6: bcd_to_seg = 7'b0000010;  // 6: a,c,d,e,f,g亮        
        4'd7: bcd_to_seg = 7'b1111000;  // 7: a,b,c亮        
        4'd8: bcd_to_seg = 7'b0000000;  // 8: 全亮        
        4'd9: bcd_to_seg = 7'b0010000;  // 9: a,b,c,d,f,g亮
    endcase
endfunction

// 特殊字符
localparam SEG_DASH = 7'b0111111;   // "-"：仅g亮
localparam SEG_BAR  = 7'b1111001;   // "|"：仅b,c亮
localparam SEG_F    = 7'b0001110;   // "F"：a,e,f,g亮
localparam SEG_A    = 7'b0001000;   // "A"：a,b,c,e,f,g亮
localparam SEG_I    = 7'b1111001;   // "I"：b,c亮
localparam SEG_L    = 7'b1000111;   // "L"：d,e,f亮
localparam SEG_OFF  = 7'b1111111;   // 全灭

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seg <= SEG_OFF;
        an  <= 4'b0000; // 共阳极位选高有效：0000 表示四位全灭
    end else begin
        case (disp_mode)
            3'd0: begin // "----"
                an  <= (4'b0001 << scan_cnt);  // 高有效，轮流选中每一位
                seg <= SEG_DASH;
            end

            3'd1: begin // "||||"
                an  <= (4'b0001 << scan_cnt);
                seg <= SEG_BAR;
            end

            3'd2: begin // 显示数值
                case (scan_cnt)
                    2'd0: begin
                        an  <= 4'b0001; // an[0] = 个位，最右位
                        seg <= bcd_to_seg(digit_u);
                    end
                    
                    2'd1: begin
                        an  <= 4'b0010; // an[1] = 十位
                        seg <= bcd_to_seg(digit_t);
                    end

                    2'd2: begin
                        an  <= 4'b0100; // an[2] = 百位
                        seg <= bcd_to_seg(digit_h);
                    end

                    2'd3: begin
                        an  <= 4'b1000; // an[3] = 千位，最左位
                        seg <= bcd_to_seg(digit_th);
                    end
                endcase
            end

            3'd3: begin  // "FAIL"，从左到右 F A I L
                case (scan_cnt)
                    2'd0: begin
                        an  <= 4'b0001; // 最右位
                        seg <= SEG_L;
                    end

                    2'd1: begin
                        an  <= 4'b0010;
                        seg <= SEG_I;
                    end

                    2'd2: begin
                        an  <= 4'b0100;
                        seg <= SEG_A;
                    end

                    2'd3: begin
                        an  <= 4'b1000; // 最左位
                        seg <= SEG_F;
                    end
                endcase
            end

            default: begin
                an  <= 4'b0000; // 全部位选关闭
                seg <= SEG_OFF;
            end
        endcase
    end
end

endmodule