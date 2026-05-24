// Cascade Counter

// All outputs are initialised to 0
// When rst is high, all outputs are set to 0 on the next rising edge of the clk
// When rst is low and enable is low, all outputs are unchanged
// When rst is low and enable is high, count0 increments on each risinge edge of the clk
// This wraps N0-1 to 0
// When count0 wraps, count1 increments, wrapping from N1-1 to 0
// When count1 wraps, count2 increments, wrapping from N2-1 to 0

`timescale 1ns / 1ps

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2 - 1:0] count2,  // When count1 is about to roll over, increments by 1
    output logic [W1 - 1:0] count1,  // When count0 is about to roll over, increments by 1
    output logic [W0 - 1:0] count0  // Increments whenever enable = 1
);

  localparam logic [W0 - 1:0] Max0 = W0'(N0 - 1);
  localparam logic [W1 - 1:0] Max1 = W1'(N1 - 1);

  logic count1_enable;  // Goes high when count0 is about to rollover and increments count1
  logic count2_enable;  // Goes high when count1 is about to rollover and increments count2

  assign count1_enable = enable && (count0 == Max0);
  assign count2_enable = enable && (count0 == Max0) && (count1 == Max1);

  mod_n_counter #(
      .N(N0),  // Max Count
      .WIDTH(W0)  // Width of Max Count
  ) u_count0 (
      .clk(clk),
      .rst(rst),  // Reset the Count (Resets the Output to 0)
      .enable(enable),  // Enable the Count
      .count(count0)  // Output the Count Value
  );

  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_count1 (
      .clk(clk),
      .rst(rst),
      .enable(count1_enable),
      .count(count1)
  );

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_count2 (
      .clk(clk),
      .rst(rst),
      .enable(count2_enable),
      .count(count2)
  );

endmodule
