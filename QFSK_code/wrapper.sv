module wrapper (
    input logic CLOCK_50,           // 50 MHz clock trên DE2
    input logic [3:0] KEY,          // Pushbuttons (KEY[0] là reset, KEY[1] là pause)
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 // 7-segment displays
);

    // Tín hi?u n?i b?
    logic clk_i;
    logic rst_ni;
    logic pause_ni;
    logic [31:0] fsw;
    logic signed [15:0] sine_out;
    logic signed [16:0] signal_with_noise;
    logic [1:0] original_symbol;
    logic [1:0] recovered_symbol;
    logic sample_ready;
    logic symbol_pulse;

    // Gán clock và reset
    assign clk_i = CLOCK_50;        // S? d?ng clock 50 MHz c?a DE2
    assign rst_ni = KEY[0];         // KEY[0] là reset active-low
    assign pause_ni = KEY[1];       // KEY[1] là pause active-low

    // Kh?i t?o module QFSK v?i pause
    qfsk u_qfsk (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .pause_ni(pause_ni),
        .fsw(fsw),
        .sine_out(sine_out),
        .signal_with_noise(signal_with_noise),
        .original_symbol(original_symbol),
        .recovered_symbol(recovered_symbol),
        .sample_ready(sample_ready),
        .symbol_pulse(symbol_pulse)
    );

    // B? ??m symbol (20-bit ?? hi?n th? t?i ?a 999,999)
    logic [19:0] symbol_count;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            symbol_count <= 0;
        end else if (symbol_pulse && pause_ni) begin
            symbol_count <= symbol_count + 1;
        end
    end

    // Chuy?n ??i sang BCD (6 digits)
    logic [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5;
    always_comb begin
        bcd0 = symbol_count % 10;           // Ch? s? ??n v?
        bcd1 = (symbol_count / 10) % 10;    // Ch? s? ch?c
        bcd2 = (symbol_count / 100) % 10;   // Ch? s? tr?m
        bcd3 = (symbol_count / 1000) % 10;  // Ch? s? nghìn
        bcd4 = (symbol_count / 10000) % 10; // Ch? s? ch?c nghìn
        bcd5 = (symbol_count / 100000) % 10;// Ch? s? tr?m nghìn
    end

    // Driver cho 7-segment display
    seg7_driver u_seg0 (.digit(bcd0), .seg(HEX0));
    seg7_driver u_seg1 (.digit(bcd1), .seg(HEX1));
    seg7_driver u_seg2 (.digit(bcd2), .seg(HEX2));
    seg7_driver u_seg3 (.digit(bcd3), .seg(HEX3));
    seg7_driver u_seg4 (.digit(bcd4), .seg(HEX4));
    seg7_driver u_seg5 (.digit(bcd5), .seg(HEX5));
    assign HEX6 = 7'b1111111;  // T?t HEX6
    assign HEX7 = 7'b1111111;  // T?t HEX7

endmodule

// Module driver cho 7-segment display
module seg7_driver (
    input logic [3:0] digit,
    output logic [6:0] seg
);
    always_comb begin
        case (digit)
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default: seg = 7'b1111111; // T?t
        endcase
    end
endmodule
