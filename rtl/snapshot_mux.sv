// Snapshot Multiplexer

// When hold is low, q follows d immediately
// When hold is high, q shows the last snapshot of d
// A snnapshot of d is captured on each rising edge of the clock while hold is low

`timescale 1ns / 1ps

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH - 1:0] d,
    output logic [WIDTH - 1:0] q
);

  // Stores the most recent sampled value of d
  logic [WIDTH - 1:0] snapshot = '0;

  // Capture d on each rising clock edge whilse hold is 0
  // Save that value in snapshot for the assign statement below
  always_ff @(posedge clk) begin
    if (!hold) begin  // Begin if hold is 0
      snapshot <= d;  // Take snapshot of input D
    end
  end

  // Remeber that snapshot is a previous value of the input
  assign q = hold ? snapshot : d;  // If hold is 1, output = snapshot, else output the input

endmodule
