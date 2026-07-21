module data_source (
    input logic clk_i,          // Clock input (50 MHz)
    input logic rst_ni,         // Active-low reset
    input logic pause_ni,
    output logic [31:0] fsw,     // Frequency selection word (32-bit)
    output logic symbol_pulse  // Tín hi?u m?i
);
    // Define constants
    localparam SYMBOL_DURATION = 33360; // 
    localparam TEXT_LENGTH = 1800;        // Example text length in bits (adjust as needed)

    // Memory array to store the text as bits
    logic text_memory [0:TEXT_LENGTH-1]; // Changed to memory array
    
    // Address counter for accessing text memory (in bits)
    logic [$clog2(TEXT_LENGTH)-1:0] bit_addr;
    
    // Timer to control symbol duration
    logic [$clog2(SYMBOL_DURATION)-1:0] symbol_timer;

    logic [1:0] current_symbol;

    // Load example text into memory at initialization
    initial begin
        $readmemb("E:/symbols.txt", text_memory); // Read into memory array
    end

    // Sequential logic to manage timing and symbol output
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            symbol_timer <= '0;
            bit_addr <= '0;
            current_symbol <= 2'b00;
            symbol_pulse <= 0;
        end else if (!pause_ni) begin
            symbol_pulse <= 0;
        end else begin
            if (symbol_timer < SYMBOL_DURATION - 1) begin
                symbol_timer <= symbol_timer + 1;
                symbol_pulse <= 0;
            end else begin
                symbol_timer <= '0;
                symbol_pulse <= 1;
                // Extract the next 2 bits from the text
                if (bit_addr < TEXT_LENGTH - 1) begin
                    current_symbol <= {text_memory[bit_addr], text_memory[bit_addr+1]}; // Extract 2 bits
                    bit_addr <= bit_addr + 2;
                end else begin
                    current_symbol <= {text_memory[1], text_memory[0]}; // Loop back to start
                    bit_addr <= 2; // Skip first 2 bits
                end
            end
        end
    end

    // Combinational logic to map 2-bit symbol to 32-bit fsw
    always_comb begin
        case (current_symbol)
            2'b00: fsw = 32'd1030792;  // 12 kHz
            2'b01: fsw = 32'd1546188;  // 18 kHz
            2'b10: fsw = 32'd2061584;  // 24 kHz
            2'b11: fsw = 32'd2576980;  // 30 kHz
            /*2'b00: fsw = 32'd2236962;  // 12 kHz
            2'b01: fsw = 32'd3355443;  // 18 kHz
            2'b10: fsw = 32'd4473924;  // 24 kHz
            2'b11: fsw = 32'd5592405;  // 30 kHz*/
            default: fsw = 32'd0;
        endcase
    end
endmodule



