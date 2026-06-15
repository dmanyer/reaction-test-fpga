// PYNQ-Z2 + common-anode 4-digit 7-seg display test
// BTN0(btn_start): 0000 -> 1111 -> ... -> 9999 -> 0000
// rst_n is active-low reset input from SW0. Put SW0 HIGH to release reset.

module seg_digit_test_top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       btn_start,   // BTN0: increment digit
    input  wire       btn_react,   // BTN1: unused, kept for XDC compatibility
    output reg  [6:0] seg,
    output reg  [3:0] an,
    output wire       dp,
    output wire [3:0] led
);

// Button synchronizer + debounce + rising-edge pulse
reg btn_sync0, btn_sync1;
reg btn_stable, btn_stable_d;
reg [21:0] debounce_cnt;

// 125 MHz clock: 2,500,000 cycles ≈ 20 ms
localparam [21:0] DEBOUNCE_MAX = 22'd2_500_000;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        btn_sync0    <= 1'b0;
        btn_sync1    <= 1'b0;
        btn_stable   <= 1'b0;
        btn_stable_d <= 1'b0;
        debounce_cnt <= 22'd0;
    end else begin
        btn_sync0 <= btn_start;
        btn_sync1 <= btn_sync0;

        if (btn_sync1 != btn_stable) begin
            if (debounce_cnt >= DEBOUNCE_MAX) begin
                btn_stable   <= btn_sync1;
                debounce_cnt <= 22'd0;
            end else begin
                debounce_cnt <= debounce_cnt + 1'b1;
            end
        end else begin
            debounce_cnt <= 22'd0;
        end

        btn_stable_d <= btn_stable;
    end
end

wire btn0_rise = btn_stable & ~btn_stable_d;

// Digit counter: 0 -> 1 -> ... -> 9 -> 0
reg [3:0] digit_value;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        digit_value <= 4'd0;
    end else if (btn0_rise) begin
        if (digit_value == 4'd9)
            digit_value <= 4'd0;
        else
            digit_value <= digit_value + 1'b1;
    end
end

// Common-anode segment code
// seg[0]=A, seg[1]=B, seg[2]=C, seg[3]=D, seg[4]=E, seg[5]=F, seg[6]=G
// Low active: 0 = ON, 1 = OFF
function [6:0] bcd_to_seg;
    input [3:0] bcd;
    begin
        case (bcd)
            4'd0: bcd_to_seg = 7'b1000000;
            4'd1: bcd_to_seg = 7'b1111001;
            4'd2: bcd_to_seg = 7'b0100100;
            4'd3: bcd_to_seg = 7'b0110000;
            4'd4: bcd_to_seg = 7'b0011001;
            4'd5: bcd_to_seg = 7'b0010010;
            4'd6: bcd_to_seg = 7'b0000010;
            4'd7: bcd_to_seg = 7'b1111000;
            4'd8: bcd_to_seg = 7'b0000000;
            4'd9: bcd_to_seg = 7'b0010000;
            default: bcd_to_seg = 7'b1111111;
        endcase
    end
endfunction

// 4-digit dynamic scanning. an is high-active for common-anode digit selection.
reg [26:0] scan_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        scan_cnt <= 27'd0;
    else
        scan_cnt <= scan_cnt + 1'b1;
end

wire [1:0] scan_sel = scan_cnt[16:15];

always @(*) begin
    seg = bcd_to_seg(digit_value);

    case (scan_sel)
        2'd0: an = 4'b0001; // rightmost digit / units
        2'd1: an = 4'b0010;
        2'd2: an = 4'b0100;
        2'd3: an = 4'b1000; // leftmost digit / thousands
        default: an = 4'b0000;
    endcase
end

assign dp = 1'b1; // common-anode: DP off

// Debug LEDs:
// led[0] = reset release status, led[1] = raw BTN0,
// led[2] = current digit LSB, led[3] = heartbeat.
assign led[0] = rst_n;
assign led[1] = btn_start;
assign led[2] = digit_value[0];
assign led[3] = scan_cnt[26];

endmodule