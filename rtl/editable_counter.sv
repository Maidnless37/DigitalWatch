// Editable Counter

// Changes how counter counts
// Counts upwards in normal mode
// Count upwards in increment edit mode
// Count downwards in decrement edit mode

`timescale 1ns / 1ps

module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             tick,       // Count increments on tick when edit_mode is low
    input  logic             edit_mode,
    input  logic             inc,        // Count increments by one when edit_mode is high
    input  logic             dec,        // Count decrements by one when edit_mode is high
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;

  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),  // If 1, allows counting to occur
      .up(up),  // If 1, counts up, but if 0, counts down.
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;  // Increment Edit Mode
  wire dec_event = edit_mode && dec && !inc;  // Decrement Edit Mode
  wire tick_event = !edit_mode && tick;  // Normal Operation

  // Counts Up in Normal and Edit Increment Mode, Counts Down in Edit Decrement Mode
  assign up     = inc_event || tick_event;

  // Counts in Normal Mode and Increment and Decrement Edit Modes
  assign enable = inc_event || dec_event || tick_event;

endmodule
