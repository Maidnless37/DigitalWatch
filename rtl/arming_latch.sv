// Arming Latch

// Variabled armed is initially 0
// If disarm is 1, armed remains/becomes 0
// If arm is 1, armed remains/becomes 1

// armed will hold 1 or 0 based on whether arm or disarm were the last at logic 1
// If both arm and disarm are simultaneously 1, disarm takes priority

// Module will change the output armed to 1 or 0 and keep it there until told otherwise

`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  initial armed = '0;

  always_ff @(posedge clk) begin  // Only updates on rising edge of clock
    if (disarm) armed <= '0;  // disarm takes priority over arm
    else if (arm) armed <= 1'b1;
  end

endmodule
