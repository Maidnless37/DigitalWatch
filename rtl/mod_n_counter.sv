// Modulo N Counter

// Reset the Count is rst is True
// Continue the Count if enable is True
// Reset the Count if count = Max

`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,  // Maximum Number to Count To
    parameter int WIDTH = 2  // Width of Maximum Number
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH - 1:0] count
);

  localparam logic [WIDTH - 1:0] Max = WIDTH'(N - 1);  // Determine Maximum Count
  localparam logic [WIDTH - 1:0] Inc = WIDTH'(1);  // Determine Increment

  logic [WIDTH - 1:0] next_count;

  initial count = '0;

  // rst takes priority over enable so the counter can always be forced back to zero (no ambiguity)
  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  always_comb
    if (count == Max) next_count = '0;
    else next_count = count + Inc;

endmodule
