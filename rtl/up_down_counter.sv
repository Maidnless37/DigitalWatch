`timescale 1ns / 1ps

module up_down_counter #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic up,
    output logic [WIDTH - 1:0] count
);

  // Enable Count
  always_ff @(posedge clk) if (enable) count <= next_count;

  // Counter (with Up Variable Input)
  localparam logic [WIDTH - 1:0] Max = WIDTH'(MAX);  // Converts 32'd2 to 2'd2
  initial count = '0;
  logic [WIDTH - 1:0] next_count;
  always_comb begin
    if (up) begin
      if (count < Max) next_count = count + WIDTH'(1);
      else next_count = '0;
    end else if (count > '0) next_count = count - WIDTH'(1);
    else next_count = Max;
  end

endmodule
