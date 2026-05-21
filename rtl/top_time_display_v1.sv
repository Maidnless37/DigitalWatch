// Variable-Speed Time Display

`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic tick_1000;  // Variables for restartable_rate_generator
  logic tick_25;
  logic tick_1;

  logic tick;  // Variables for hms_counter
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic [3:0] seconds_ones;  // Variables for binary_to_bcd
  logic [3:0] seconds_tens;
  logic [3:0] minutes_ones;
  logic [3:0] minutes_tens;
  logic [3:0] hours_ones;
  logic [3:0] hours_tens;

  // 1 kHz Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)  // Number of Cycles before a Tick
  ) u_tick_1000 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1000)
  );

  // 25 Hz Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)  // Number of Cycles before a Tick
  ) u_tick_25 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25)
  );

  // 1 Hz Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)  // Number of Cycles before a Tick
  ) u_tick_1 (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1)
  );

  always_comb
    unique case (SW)
      2'b00: tick = tick_1;
      2'b01: tick = tick_25;
      2'b10: tick = tick_1000;
      2'b11: tick = 1'b1;  // Tick 50 MHz
    endcase

  hms_counter u_hms_counter (
      .clk(CLOCK_50),
      .enable(tick),  // Enables Module when Tick Permits
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  binary_to_bcd u_seconds (
      .bin ({1'b0, seconds}),  // Concatenation to Add Zeroes to Match 7-bit Binary Input
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  binary_to_bcd u_minutes (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );

  binary_to_bcd u_hours (
      .bin ({2'b0, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );

  seven_segment u_seconds_ones (  // Plug in Value for the Ones Digit of the Seconds
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

  seven_segment u_seconds_tens (  // Plug in Value for the Tens Digit of the Seconds
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment u_minutes_ones (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment u_minutes_tens (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment u_hours_ones (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment u_hours_tens (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );

endmodule
