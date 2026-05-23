// Rising-Edge Detector

// Detects a 0 -> 1 Transition (Rising Edge of a Variable) and Generates a Short Pulse
// Pulse continues until sig_in = 0
// Only outputs a 1 whilst prievious value is 0 and current value is 1

// Essentially converts a signal staying at 1 (11111) into (10000)

`timescale 1ns / 1ps

module rising_edge_detector (
    input logic clk,
    input logic sig_in,  // Input Signal of 1 or 0
    output logic rise  // Outputs a 1 Until the next Rising Edge of the Clock or Until in_sig is 0
);

  logic prev_sig;
  initial prev_sig = '0;  // Ensures rise is 1 only if sig_in transitions from 0 to 1

  always_ff @(posedge clk) prev_sig <= sig_in;

  assign rise = !prev_sig && sig_in;  // Ensures the Previous Signal was 0 and Current Signal is 1

endmodule
