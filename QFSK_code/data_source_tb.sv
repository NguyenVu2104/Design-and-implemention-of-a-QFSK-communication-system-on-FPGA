`timescale 1ns/1ns

module data_source_tb;
    // ??nh ngh?a tín hi?u ki?m tra
    logic clk_i;           // Clock input
    logic rst_ni;          // Active-low reset
    logic [31:0] fsw;      // Frequency selection word output

    // Kh?i t?o module data_source
    data_source dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .fsw(fsw)
    );

    // T?o tín hi?u clock 23.04 MHz (chu k? ~43.4ns)
    initial begin
        clk_i = 0;
        forever #21.7 clk_i = ~clk_i; // 23.04 MHz: 1 chu k? = ~43.4ns
    end

    // Kh?i t?o và ki?m tra
    initial begin
        // Kh?i t?o reset
        rst_ni = 0;
        #100 rst_ni = 1; // Reset trong 100ns

        // Hi?n th? n?i dung c?a text_memory ?? ki?m tra d? li?u t? file
        $display("Content of text_memory after reading from E:/symbols.txt:");
        for (int i = 0; i < dut.TEXT_LENGTH; i++) begin
            $write("%b", dut.text_memory[i]);
        end
        $display("\n");

        // Ch? và ki?m tra ??u ra qua các ký hi?u
        #1_000_000; // Ch? ~43.5us ?? quan sát ??u ra ??u tiên (1 symbol = 0.667ms)
        $display("Time=%0t: fsw=%0d (symbol=00, expected=2236962)", $time, fsw);

        #1_000_000; // Ch? thêm ~43.5us ?? sang symbol ti?p theo
        $display("Time=%0t: fsw=%0d (symbol=10, expected=4473924)", $time, fsw);

        #1_000_000; // Ch? thêm ~43.5us ?? sang symbol ti?p theo
        $display("Time=%0t: fsw=%0d (symbol=11, expected=5592405)", $time, fsw);

        #1_000_000; // Ch? thêm ~43.5us ?? sang symbol ti?p theo
        $display("Time=%0t: fsw=%0d (symbol=10, expected=4473924)", $time, fsw);

        #1_000_000; // Ch? thêm ~43.5us ?? ki?m tra l?p l?i
        $display("Time=%0t: fsw=%0d (symbol=00, expected=2236962)", $time, fsw);

        // K?t thúc mô ph?ng
        #100 $finish;
    end

    // Theo dõi và ki?m tra l?i
    always @(posedge clk_i) begin
        if (rst_ni) begin
            case (fsw)
                32'd2236962: if (dut.current_symbol !== 2'b00) $display("ERROR: fsw 2236962 should map to symbol 00 at time %0t", $time);
                32'd3355443: if (dut.current_symbol !== 2'b01) $display("ERROR: fsw 3355443 should map to symbol 01 at time %0t", $time);
                32'd4473924: if (dut.current_symbol !== 2'b10) $display("ERROR: fsw 4473924 should map to symbol 10 at time %0t", $time);
                32'd5592405: if (dut.current_symbol !== 2'b11) $display("ERROR: fsw 5592405 should map to symbol 11 at time %0t", $time);
                default: $display("WARNING: Unexpected fsw value %0d at time %0t", fsw, $time);
            endcase
        end
    end
endmodule
