// Restartable Rate Generator

// Implemented as a Moore FSM
// -    The outputs depend only on current state rather than directly on inputs

// Turns clk clk clk clk clk clk clk clk clk clk into 0 0 0 1 0 0 0 1 0 0
// Tick = 0 where Run = 0
// Module Counts Cycles when Run = 1
// After the Required Number of Cycles, Tick = 1 for One Cycle

// $clog(x) = ceiling(log2(x))
// The minimum number of bits required to represent x states
// $clog(2) = ceiling(log2(2)) = 1
// $clog(4) = ceiling(log2(4)) = 2
// $clog(8) = ceiling(log2(8)) = 3
// Rounds Up --> $clog(3) = ceiling(log2(3)) = 2.32 = 3
// Note that $clog(1) = 0

`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2  // Number of Clock Cycles between each Tick
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  logic tick_qualifier;

  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;

  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general  // If a parameter has a certain value, build this
      localparam int CountWidth = $clog2(CYCLE_COUNT);  // CountWidth = 1 if CYCLE_COUNT = 2

      logic rst_count;
      logic enable_count;
      logic [CountWidth - 1:0] count;
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      assign rst_count = !run;  // No width specified as this is a 1-bit control variable
      assign enable_count = run;

      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));
    end else begin : g_special  // Otherwise, build this instead
      assign tick_qualifier = 1'b1;
    end
  endgenerate

endmodule
