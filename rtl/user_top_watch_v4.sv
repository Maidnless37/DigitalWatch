// Timekeeping (Watch V1)

// Basic Non-Editable Timekeeping Watch
// Contains suppressed variables

`timescale 1ns / 1ps

module user_top_watch_v4 #(
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

  logic clock_divider_run;  // Addition of V4, see implementation in restartable_rate_generator

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
      .run (clock_divider_run),  // Updated as of V4 (See Below for Information)
      .tick(seconds_tick)
      // When .run is 0, it stops the rate generator
      // The rate generator will restart its count, so it also acts as a reset on the seconds
      // The seconds are realigned to tick exactly one second after moving from edit second to mins
  );

  // Minutes and Hours Tick after 60 Seconds
  // Altered code from V1 to stop rollover when a field is being editied
  assign minutes_tick = seconds_tick && (seconds == 6'd59);
  assign hours_tick = minutes_tick && (minutes == 6'd59);

  // Zero-Extend Counter Values to Display Outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Unused Output Ports
  assign led = 10'b0;

  // Addition of V4 - Variable = 0 when you are editing seconds AND you press the mode button again
  // Divider only receives a 0 briefly when switching from seconds to minutes in edit mode
  // This is used in the restartable rate generator above
  assign clock_divider_run = !(button[3] && mode_enable[0]);

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;

  pwm_generator #(  // Outputs 1111111100 at 2Hz (Count the 1s and 0s and you'll see 80% duty cycle)
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),  // Period and Frequency are Inverse (Gives us 2 Hz)
      .DUTY_CYCLES((CYCLES_PER_SECOND / 2) * 8 / 10)  // 80% Duty Cycle
  ) u_pwm_generator (
      .clk(clk),
      .rst(mode_enable == 3'b000),
      .pwm_out(pwm_out)  // Outputs 1111111100 (2hz 80% duty cycle, so 80% 1, 20% 0 at 2 Hz)
  );

  // mode_enable[0] = 1 if mode_enable = 3'b001 (editing seconds)
  // !pwm_out = 1 when pwm_out = 0 (1111111100 80% duty cycle 2Hz)
  // When in seconds mode && for 20% of the time, seconds will be blank
  // This creates the flashing
  assign blank_seconds = mode_enable[0] && !pwm_out;
  assign blank_minutes = mode_enable[1] && !pwm_out;
  assign blank_hours   = mode_enable[2] && !pwm_out;

  // ----------------------------
  // Specification Implementation
  // ----------------------------

  // This relates to Section 7.15 Settable Watch (V3)

  logic inc_pulse;
  logic dec_pulse;

  // Cycle Through Numbers in Edit Mode Upwards
  button_auto_repeat #(
      .HOLD_CYCLES(CYCLES_PER_SECOND / 2), // Hold for more than 0.5s to cycle through number quickly
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // How quickly to cycle through numbers (10 Hz)
  ) u_inc_button_auto_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  // Cycle Through Numbers in Edit Mode Downwards
  button_auto_repeat #(
      .HOLD_CYCLES(CYCLES_PER_SECOND / 2), // Hold for more than 0.5s to cycle through number quickly
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // How quickly to cycle through numbers (10 Hz)
  ) u_dec_button_auto_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  // Edit seconds/minutes/hours based on mode_enable
  assign seconds_edit = mode_enable[0];
  assign minutes_edit = mode_enable[1];
  assign hours_edit = mode_enable[2];

  // Increment seconds/minutes/hours based on mode_enable
  assign seconds_inc = mode_enable[0] && inc_pulse;
  assign minutes_inc = mode_enable[1] && inc_pulse;
  assign hours_inc = mode_enable[2] && inc_pulse;

  // Decrement seconds/minutes/hours based on mode_enable
  assign seconds_dec = mode_enable[0] && dec_pulse;
  assign minutes_dec = mode_enable[1] && dec_pulse;
  assign hours_dec = mode_enable[2] && dec_pulse;

endmodule
