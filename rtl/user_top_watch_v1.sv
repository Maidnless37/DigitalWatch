// Timekeeping (Watch V1)

// Basic Non-Editable Timekeeping Watch
// Contains suppressed variables

`timescale 1ns / 1ps

module user_top_watch_v1 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */  // Suppress these two input linter warnings as they are unused
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------
  // Core Functionality
  // ------------------

  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;

  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;

  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;

  // Alterations in Counter --> Creates an Edit Mode with Increments and Decrements (Unused for Now)

  // Seconds
  editable_counter #(
      .N(60),  // Max Count
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),  // CLOCK_50 runs 1111111111 but seconds_tick is 1000010000
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Minutes
  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Derive 1 Hz Tick from System Clock (Variable of Focus: seconds_tick)
  restartable_rate_generator #(  // Gives us our ticks for the editable_counter
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  // Since this version has no edit functionality, assign it as low (Variable of Focus: seconds_edit)
  assign seconds_edit = 1'b0;
  assign seconds_inc = 1'b0;
  assign seconds_dec = 1'b0;

  // Since this version has no edit functionality, assign it as low (Variable of Focus: minutes_edit)
  assign minutes_edit = 1'b0;
  assign minutes_inc = 1'b0;
  assign minutes_dec = 1'b0;

  // Since this version has no edit functionality, assign it as low (Variable of Focus: hours_edit)
  assign hours_edit = 1'b0;
  assign hours_inc = 1'b0;
  assign hours_dec = 1'b0;

  assign minutes_tick = seconds_tick && (seconds == 6'd59);  // Minutes Tick after 60 Seconds
  assign hours_tick = minutes_tick && (minutes == 6'd59);  // Hours Tick after 60 Minutes

  // Zero-Extend Counter Values to Display Outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Unused Output Ports
  assign led = 10'b0;
  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

endmodule
