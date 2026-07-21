`timescale 1ns/1ps

module dds_tb;

  // Parameters for simulation
  localparam int FSW_VALUE = 869;  // Frequency control word for ~10 kHz sine output
  
  // Testbench signals
  logic           clk_i;     // System clock (50 MHz)
  logic           rst_ni;    // Active-low reset
  logic [31:0]    fsw;       // Frequency control word input
  logic [15:0]    sine_out;  // DDS output sine wave (14-bit signed)

  // Instantiate the DUT (DDS module)
  dds uut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .fsw(fsw),
    .sine_out(sine_out)
  );

  // Clock generation: 50 MHz clock, period = 20ns
  initial begin
    clk_i = 0;
    forever #10 clk_i = ~clk_i;
  end

  // Reset generation: hold reset active low for 50 ns then release
  initial begin
    rst_ni = 1'b0;
    #50;
    rst_ni = 1'b1;
  end

  // Stimulus for frequency word
  initial begin
    fsw = 32'd2000;
  end

  // Dump waveform for simulation
  initial begin
    // Run simulation long enough to see several sine cycles
  end

  // Monitor key signals
  initial begin
    $display("Time(ns) | fsw   | sine_out");
    $monitor("%0t     | %0d | %0d", $time, fsw, sine_out);
  end

endmodule

