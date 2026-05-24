// Stopwatch Counter

// Counts the centiseconds, seconds, and minutes
// First centisecond increment occurs 10 ms (or 1 centisecond) after enable is 1
// Note that 10 ms = 1 centisecond

`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  logic centisecond_tick;

  // Determines the tick rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)  // 100 centiseconds per second, 1 centisecond = 10 ms
  ) u_centisecond_rate (
      .clk (clk),
      .run (enable && !rst),   // Essentially allows the module to run
      .tick(centisecond_tick)
  );

  // Allocates that tick rate from rate generator and cascades it with max count specifications
  cascade_counter #(
      .N2(100),  // As per design instructions, minutes counts from 0 - 99 before wrappings
      .N1(60),   // Seconds counts from 0 - 59 before wrapping
      .N0(100),  // Centiseconds counts from 0 - 99 before wrapping
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_stopwatch_count (
      .clk(clk),
      .rst(rst),
      .enable(enable && centisecond_tick),  // Increments count0 every centisecond_tick
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
