module channel (
    input logic clk_i,                    // Clock input
    input logic rst_ni,                   // Active-low reset
    input logic signed [15:0] signal_in,  // Input signal (e.g., sine_out from DDS)
    output logic signed [16:0] signal_out // Output signal with added noise (16-bit signed)
);
    // Parameters
    localparam LFSR_MIN_VALUE = 12'd2000; // Minimum LFSR value

    // Internal signals
    logic [11:0] lfsr_reg;                // LFSR register (12-bit)
    logic [11:0] lfsr_constrained;        // LFSR value constrained to be >= 2000

    // LFSR for pseudo-random noise generation (12-bit)
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            lfsr_reg <= 12'hACE;          // Initial seed (0xACE = 2766, above 2000)
        end else begin
            // Feedback polynomial: x^12 + x^11 + x^10 + x^4 + 1
            lfsr_reg <= {lfsr_reg[10:0], lfsr_reg[11] ^ lfsr_reg[10] ^ lfsr_reg[9] ^ lfsr_reg[3]};
        end
    end

    // Constrain LFSR value to be >= 2000
    always_comb begin
        if (lfsr_reg < LFSR_MIN_VALUE) begin
            lfsr_constrained = LFSR_MIN_VALUE;
        end else begin
            lfsr_constrained = lfsr_reg;
        end
    end

    // Add noise to the input signal
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            signal_out <= 17'd0;
        end else begin
            // Directly add LFSR value as noise (signal_out is 21-bit to accommodate the wider range)
            signal_out <= $signed({{1{signal_in[15]}}, signal_in}) + $signed({{5{lfsr_constrained[11]}}, lfsr_constrained});
        end
    end
endmodule
