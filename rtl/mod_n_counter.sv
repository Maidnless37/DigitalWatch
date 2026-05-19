// Modulo N Counter

`timescale 1ns / 1ps

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH - 1:0] count
);

  localparam logic [WIDTH - 1:0] Max = WIDTH'(N - 1);
  localparam logic [WIDTH - 1:0] Inc = WIDTH'(1);  // Increment Count

  logic [WIDTH - 1:0] next_count;

  initial count = '0;

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  always_comb
    if (count == Max) next_count = '0;
    else next_count = count + Inc;

endmodule
