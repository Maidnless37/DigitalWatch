// Edit Mode Selector

`timescale 1ns / 1ps

// 3'b000 No Field Selected
// 3'b001 Edit Seconds
// 3'b010 Edit Minutes
// 3'b100 Edit Hours

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);

  // Emmits a single pulse once button has been pressed for long enough (HOLD_CYCLES amount of time)
  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  // Converts the button press from 111111 (in 50MHz clk cycles) into 10000
  // Basically so one press of the button translates to an input of only 1, not 1111111...
  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  // Activates mode_enable through arm being linked to long_press (outputs constant 111 or 000)
  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  // Stores which edit mode we are in (seconds, minutes, hours) and wraps back around to them
  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // Counter runs only while armed; resets when disarmed
  assign enable_counter = armed && press;  // Only increment counter when armed and button pressed
  assign reset_counter = !armed;  //  Also resets counter when count <= N as per mod n module

  // Disarm on the press that steps past the last mode
  // Needs to be armed, need to press button to allow next mode, and mod n count needs to be maxed
  assign disarm = armed && press && count == 2'd2;

  // Output logic
  // [2:0] mode_enable outputs what the current editing mode is
  // << shifts the binary left by count amount
  // When armed = 1 and count = 0 (count = 0 is from mod_n_counter for seconds), 3'b001 << 0 = 001
  // When armed = 1 and count = 1, 3'b001 << 1 = 010 (for edit the minutes)
  // WHen armed = 1 and count = 2, 3'b001 << 2 = 100 (for edit the hours)
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
