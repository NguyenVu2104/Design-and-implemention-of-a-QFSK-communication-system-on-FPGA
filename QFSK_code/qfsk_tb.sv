`timescale 1ns/1ns

module qfsk_tb;
    // Testbench signals
    logic clk_i;           // System clock
    logic rst_ni;          // Active-low reset
    logic [31:0] fsw;      // Frequency selection word from data_source
    logic signed [15:0] sine_out;          // Sine wave output from DDS
    logic signed [16:0] signal_with_noise; // Signal with noise from channel
    logic [1:0] original_symbol;           // Original symbol from data_source
    logic [1:0] recovered_symbol;          // Recovered symbol from decision

    // Instantiate the DUT (Device Under Test)
    qfsk dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .fsw(fsw),
        .sine_out(sine_out),
        .signal_with_noise(signal_with_noise),
        .original_symbol(original_symbol),
        .recovered_symbol(recovered_symbol)
    );


    initial begin
        clk_i = 0;
        forever #10 clk_i = ~clk_i; // 20 ns half-period
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst_ni = 0;
        #100; // Hold reset for 100 ns
        rst_ni = 1;

        // Wait for multiple symbol periods to observe demodulation
        #200_000_000; // Run for ~2 ms (approx. 0.667 ms * 3 symbols)
    end

    // Monitor output for console verification
    initial begin
        $monitor("Time=%0t ns: fsw=%d, sine_out=%d, signal_with_noise=%d, original_symbol=%b, recovered_symbol=%b", 
                 $time, fsw, sine_out, signal_with_noise, original_symbol, recovered_symbol);
    end

    // Check if recovered_symbol matches original_symbol when sample_ready is high
    always @(posedge clk_i) begin
        if (rst_ni && (original_symbol !== recovered_symbol)) begin
            $display("Mismatch at time %0t: original_symbol=%b, recovered_symbol=%b", $time, original_symbol, recovered_symbol);
        end
    end
endmodule

