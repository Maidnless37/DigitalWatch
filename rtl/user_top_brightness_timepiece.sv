// Brightness Timepiece

// RENAMED FROM user_top_brightness_timepiece_v1.sv TO user_top_brightness_timepiece.sv FOR PYTEST

// This module instantiates user_top_timepiece and passes through the display outputs
// It then modifites the blanking signals to reduce display brightness

`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
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

  // Original blanking signal from user_top
  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  // Creates a PWM frequency of 1000 Hz which is fast enough to avoid the visible flicker
  localparam int PwmPeriodCycles = CYCLES_PER_SECOND / 1000;
  localparam int PwmWidth = $clog2(PwmPeriodCycles);

  logic [PwmWidth-1:0] pwm_count;
  logic [PwmWidth-1:0] duty_cycles;
  logic full_brightness;
  logic pwm_blank;

  //Generates a repeating counter that acts as the PWM time base
  mod_n_counter #(
      .N(PwmPeriodCycles),
      .WIDTH(PwmWidth)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  // Determines the full brightness switch position
  assign full_brightness = sw[9] && !sw[8];  // No blanking at full brightness

  // sw[9:8] determines Duty Cycles
  // Means 00 --> Period / 8, 01 --> Period / 4, 10 --> Period / 2
  assign duty_cycles = sw[9] ? PwmWidth'(PwmPeriodCycles / 2) :
                       sw[8] ? PwmWidth'(PwmPeriodCycles / 4) :
                               PwmWidth'(PwmPeriodCycles / 8);

  // If the pwm_count is below the duty_cycles, and it is not set to full brightness, display is on
  // If pwm_count is less than duty_cycles and it is not full brightness, pwm_blank is 1
  assign pwm_blank = !full_brightness && !(pwm_count < duty_cycles);

  assign blank_hours = app_blank_hours || pwm_blank;
  assign blank_minutes = app_blank_minutes || pwm_blank;
  assign blank_seconds = app_blank_seconds || pwm_blank;
endmodule
