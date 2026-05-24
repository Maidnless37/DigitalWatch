// Stopwatch Control

// Controls the stopwatch using two single-cycle button pulses
// rise_start_stop toggles between running and stopped
// rise_lap freezes/unfreezes the display while running
// rise_lap resets the counter only when stopped and live
// simultaneous button presses are ignored

`timescale 1ns / 1ps

module stopwatch_control (
    input logic clk,
    input logic rise_start_stop,  // Toggles between the counter runnings and freezing
    input logic rise_lap,  // Freezes the display but keeps the count runnings
    output logic counter_rst,  // Generates a reset pulse that resets the counter
    output logic counter_enable,  // Controlls whether the stopwatch is counting
    output logic lap_hold  // Controlls whether the stopwatch shows a live counter or the frozen lap
);

  // Define next-state logic variables
  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;


  // Next-State Logic for next_counter_enable
  // Start/stop toggles running state, unless both buttons are pressed
  // XOR stops both buttons being pressed
  assign next_counter_enable = counter_enable ^ (rise_start_stop && !rise_lap);

  // Next-State Logic for next_counter_rst
  // Reset only occurs when stopped, live, and lap/reset is pressed by itself
  assign next_counter_rst = rise_lap && !rise_start_stop && !counter_enable && !lap_hold;

  // Next-State Logic for next_lap_hold
  // Lap button toggles hold when running or already frozen
  // If stopped and live, it resets instead, so lap_hold stays low
  always_comb begin
    next_lap_hold = lap_hold;

    if (rise_lap && !rise_start_stop) begin
      if (counter_enable || lap_hold) begin
        next_lap_hold = !lap_hold;
      end
    end
  end

  always_ff @(posedge clk) begin
    counter_rst <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold <= next_lap_hold;
  end

  initial begin
    counter_rst = 1'b0;
    counter_enable = 1'b0;
    lap_hold = 1'b0;
  end

endmodule
