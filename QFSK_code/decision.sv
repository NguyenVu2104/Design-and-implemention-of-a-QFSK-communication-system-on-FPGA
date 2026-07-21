// Module comparator
module comparator (
    input logic [46:0] energy_12k,
    input logic [46:0] energy_18k,
    input logic [46:0] energy_24k,
    input logic [46:0] energy_30k,
    output logic [1:0] max_index
);
always_comb begin
  if (energy_12k >= energy_18k && energy_12k >= energy_24k && energy_12k >= energy_30k)
    max_index = 2'b00;
  else if (energy_18k >= energy_12k && energy_18k >= energy_24k && energy_18k >= energy_30k)
    max_index = 2'b01;
  else if (energy_24k >= energy_12k && energy_24k >= energy_18k && energy_24k >= energy_30k)
    max_index = 2'b10;
  else
    max_index = 2'b11;   // final else covers all remaining cases
end

endmodule

// Module decision
module decision (
    input logic [1:0] max_index,
    output logic [1:0] symbol
);
    always_comb begin
        case (max_index)
            2'b00: symbol = 2'b00; // 12 kHz -> 00
            2'b01: symbol = 2'b01; // 18 kHz -> 01
            2'b10: symbol = 2'b10; // 24 kHz -> 10
            2'b11: symbol = 2'b11; // 30 kHz -> 11
            default: symbol = 2'b00;
        endcase
    end
endmodule
