// Editable Countdown with Borrow Out

// Normal Mode
// - count decrements on each tick pulse

// Edit Mode
// - inc increments count
// - dec decrements count
// - if inc and dec are both high, count does not change

// Clear
// - clr resets count to zero on the next rising clock edge
// - clr takes priority over all other inputs

// borrow_out
// - combinational output for cascading countdown counters
// - high when this counter is at zero and receives a tick in normal mode
// - low during edit mode or clear

`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out
);

  logic enable;
  logic up;

  logic inc_event;
  logic dec_event;
  logic tick_event;

  assign inc_event = edit_mode && inc && !dec;  // Increment if editing, inc pressed and not dec
  assign dec_event = edit_mode && dec && !inc;  // Decrement if editing, dec pressed and not inc
  assign tick_event = !edit_mode && tick;  // Only tick if not in edit mode AND a tick occurs

  // In edit mode, inc counts up and dec counts down
  // In normal mode, tick counts down (rather than up as previously used in a similar modules)
  assign up = inc_event;

  // Counter changes for exactly one valid event
  // Allows counter to change for any of these three evvents
  assign enable = inc_event || dec_event || tick_event;  // If none of these occur, no count change

  // Borrow occurs when a normal countdown tick arrives while count is zero
  // Determines when the modules tells the next higher counter to decrements
  // For example, minutes = 12 seconds = 00, ensures minutes = 11 seconds = 59 next
  assign borrow_out = tick_event && (count == '0) && !clr;

  up_down_counter_rst #(
      .MAX  (MAX),   // Maximum Count before it Wraps Around
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),  // Resets Counter
      .enable(enable),  // Allows Counting Increments
      .up(up),  // 1 for Increments, 0 for Decrements
      .count(count)
  );

endmodule
