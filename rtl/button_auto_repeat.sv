// Button Auto Repeat

// Generates one pulse immediately, then repeated pulses after the button is held

`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train); // pulse = 1 if rise or (button & pulse_train) are 1

  // Immediate Pulse from rising_edge_detector
  rising_edge_detector u_rising_edge_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  // If button stays held long enough from button_hold_detect
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_button_hold_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Repeated pulses from restartable_rate_generator
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)  // pulse_train = 1 for every REPEATED_CYCLES
  );

endmodule
