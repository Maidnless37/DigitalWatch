// Binary to Binary-Coded Decimal Converter

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // Binary Input 0-99
    output logic [3:0] tens,  // Decimal Tens Digit (BCD)
    output logic [3:0] ones   // Decimal Ones Digit (BCD)
);

  assign tens = 4'(bin / 7'd10);  // Cast to 4-bits (match bit width of tens)
  assign ones = 4'(bin % 7'd10);  // Divide by 7-bits (match bit width of bin)

endmodule
