// Binary to Binary-Coded Decimal Converter

// BCD = Binary-Coded Decimal
// 4-bits per decimal digit
// 00010010 --> 0001 0010 --> tens digit = 1 and ones digit = 2

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   // Binary Input 0-99
    output logic [3:0] tens,  // Decimal Tens Digit (BCD)
    output logic [3:0] ones   // Decimal Ones Digit (BCD)
);

  // Divide binary by 10 to get tens digit and the remainder of that division is the ones digit
  assign tens = 4'(bin / 7'd10);  // Cast to 4-bits (match bit width of tens)
  assign ones = 4'(bin % 7'd10);  // Divide by 7-bits (match bit width of bin)

endmodule
