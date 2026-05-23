// Button Hold Pulse

// button_hold_detect outputs a 1 once a button has been pressed for long enough (HOLD_CYCLES)
// It will continue to output a 1 if the button is held down
// rising_edge_detector ensures that only a single pulse at the first clk cycle is outputted
// OVERALL: ensures a single signal is sent rather than a continuous logic high

// The output from this module will be a single pulse once the button has been pressed long enough
// This module converts from 0000111111111 -> 0000100000000

`timescale 1ns / 1ps

module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic held;

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
