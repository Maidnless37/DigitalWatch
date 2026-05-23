// Button Hold Detect

`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CountMax = HOLD_CYCLES;  // Threshold at which held asserts
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth - 1:0] count;
  mod_n_counter #(
      .N(CountMax + 1),  // Counter counts from 0 to CountMax
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // Next State Logic
  assign count_rst = !button;  // Resets the mod_n_counter when the button is released
  assign count_enable = (button && !held);  // Count while button is pressed, stop once held asserts

  // Output Logic
  assign held = (count == CountWidth'(CountMax));  // Outputs high when count reaches the threshold

endmodule
