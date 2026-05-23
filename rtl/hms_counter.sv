// Counter for Hours, Minutes, Seconds

`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,  // Number of Hours
    parameter int N_MINUTES = 60,  // Number of Minutes
    parameter int N_SECONDS = 60,  // Number of Seconds

    // Output Port Widths
    parameter int W_HOURS   = 5,  // Width of Hours
    parameter int W_MINUTES = 6,  // Width of Minutes
    parameter int W_SECONDS = 6   // Width of Seconds
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS - 1:0] hours,
    output logic [W_MINUTES - 1:0] minutes,
    output logic [W_SECONDS - 1:0] seconds
);

  localparam logic [W_MINUTES - 1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);  // Define Next Digit
  localparam logic [W_SECONDS - 1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  logic minute_rollover;
  logic second_rollover;

  // Logic for Next Digit
  assign minute_rollover = (second_rollover && enable) && (minutes == MaxMinutes);
  assign second_rollover = enable && (seconds == MaxSeconds);

  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),  // Signal that Next Hour has Arrived
      .up(1'b1),
      .count(hours)
  );

  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),  // Signal that Next Minute has Arrived
      .up(1'b1),
      .count(minutes)
  );

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up(1'b1),
      .count(seconds)
  );

endmodule
