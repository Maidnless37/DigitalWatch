// Personal Test for Restartable Rate Generator

// Tests CYCLE_COUNT = 1

`timescale 1ns / 1ps

module personal_test_restartable_rate_generator;

  reg  clk = 0;
  reg  run = 0;
  wire tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) u (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  always #5 clk = ~clk;

  initial begin

    run = 0;
    #20;

    if (tick !== 0) $display("ERROR: tick should be 0");

    run = 1;
    #20;

    if (tick !== 1) $display("ERROR: tick should follow run");

    run = 0;
    #20;

    if (tick !== 0) $display("ERROR: tick should return low");

    $display("TEST COMPLETE");
    $finish;
  end

endmodule
