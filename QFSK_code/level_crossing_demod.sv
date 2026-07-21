module level_crossing_demod (
    input logic clk_i,                  // Clock input (50 MHz)
    input logic rst_ni,                 // Active-low reset
    input logic signed [15:0] signal_in, // Input signal from channel
    output logic [1:0] symbol           // QFSK symbol (00, 01, 10, 11)
);
    // Parameters
    localparam THRESHOLD_POS = 16'd20000;  // Positive threshold value
    localparam THRESHOLD_NEG = -16'd20000; // Negative threshold value
    localparam SYMBOL_DURATION = 33360;    // Number of cycles in one frame (0.667 ms at 50 MHz)

    // Internal signals
    logic [15:0] crossing_pos_count;       // Count of crossings above positive threshold
    logic [15:0] crossing_neg_count;       // Count of crossings below negative threshold
    logic [15:0] prev_sample;              // Previous sample value
    logic [$clog2(SYMBOL_DURATION)-1:0] timer; // Timer to track frame duration
    logic processing;                      // Processing state flag
    logic [15:0] cycle_count;

    // Sequential logic for counting cycles and determining symbol
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            crossing_pos_count <= 0;         // Reset positive crossing count
            crossing_neg_count <= 0;         // Reset negative crossing count
            prev_sample <= 0;                // Reset previous sample
            timer <= 0;                      // Reset timer
            processing <= 0;                 // Reset processing state
            symbol <= 2'b00;                 // Reset symbol to default
        end else begin
            if (timer < SYMBOL_DURATION - 1) begin
                timer <= timer + 1;          // Increment timer
                // Count positive threshold crossings
                if (prev_sample < THRESHOLD_POS && signal_in >= THRESHOLD_POS) begin
                    crossing_pos_count <= crossing_pos_count + 1;
                end
                // Count negative threshold crossings
                if (prev_sample > THRESHOLD_NEG && signal_in <= THRESHOLD_NEG) begin
                    crossing_neg_count <= crossing_neg_count + 1;
                end
                prev_sample <= signal_in[15:0]; // Update previous sample with 16-bit input
            end else begin
                // End of frame, calculate cycle count and map to symbol
                cycle_count = (crossing_pos_count + crossing_neg_count) / 2;

                if (cycle_count < 10) begin
                    symbol <= 2'b00; // 12 kHz
                end else if (cycle_count < 15) begin
                    symbol <= 2'b01; // 18 kHz
                end else if (cycle_count < 20) begin
                    symbol <= 2'b10; // 24 kHz
                end else begin
                    symbol <= 2'b11; // 30 kHz
                end

                // Reset for next frame
                crossing_pos_count <= 0;
                crossing_neg_count <= 0;
                timer <= 0;
            end
        end
    end
endmodule
