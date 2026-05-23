// Parametrised Up-Down Counter with Enable

`timescale 1ns / 1ps

// If enable = 1 and up = 1, +1 to count every clk cycle
// When it reaches Max, wraps back to 0
// If enable = 1 and up = 0, -1 to count every clk cycle
// When it reaches 0, wraps back to Max
// If enable = 0, count does not change

module up_down_counter #(
    parameter int MAX   = 2,  // Largest Count Value
    parameter int WIDTH = 2   // Number of Bits in Counter
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH - 1:0] count
);

  // Enable Count
  always_ff @(posedge clk) if (enable) count <= next_count;  // Increment count

  // Counter (with Up Variable Input)
  localparam logic [WIDTH - 1:0] Max = WIDTH'(MAX);  // Converts 32'd2 to 2'd2

  initial count = '0;

  logic [WIDTH - 1:0] next_count;

  always_comb begin
    if (up) begin
      if (count < Max) next_count = count + WIDTH'(1);  // next_count + 1
      else next_count = '0;  // Wrap around
    end else if (count > '0) next_count = count - WIDTH'(1);  // next_count - 1
    else next_count = Max;  // Wrap around
  end

endmodule
