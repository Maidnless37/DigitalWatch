// Stopwatch Integration

// Displays minutes, seconds, and centiseconds
// button[0] = start/stop
// button[1] = lap/reset

`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,  // Wrap button because [3:2] button are not used
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ----------------
  // Button Detection
  // ----------------

  logic rise_start_stop;
  logic rise_lap;

  // Outputs a 1 when button[i] is pressed, ensured only one pulse is received
  rising_edge_detector u_start_stop_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_stop)
  );

  rising_edge_detector u_lap_edge (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise_lap)
  );

  // ------------------
  // Stopwatch Controls
  // ------------------

  logic counter_rst;
  logic counter_enable;
  logic lap_hold;

  stopwatch_control u_stopwatch_control (
      .clk(clk),
      .rise_start_stop(rise_start_stop),
      .rise_lap(rise_lap),
      .counter_rst(counter_rst),  // resets the counter
      .counter_enable(counter_enable),  // runs/stops the counter
      .lap_hold(lap_hold)  // freezes/unfreezes the display
  );

  // -----------------
  // Stopwatch Counter
  // -----------------

  logic [6:0] live_minutes;
  logic [5:0] live_seconds;
  logic [6:0] live_centiseconds;

  // Produces the Live Time mintes, seconds, and centiseconds
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(live_minutes),
      .seconds(live_seconds),
      .centiseconds(live_centiseconds)
  );

  // ----------------
  // Snapshot Display
  // ----------------

  logic [19:0] live_time;
  logic [19:0] display_time;

  assign live_time = {live_minutes, live_seconds, live_centiseconds};

  // Chooses between displaying constantly updated live_time, and saved display_time
  // Determined by lap_hold
  snapshot_mux #(
      .WIDTH(20)
  ) u_snapshot_mux (
      .clk(clk),
      .hold(lap_hold),
      .d(live_time),
      .q(display_time)
  );

  assign {hours_disp, minutes_disp[5:0], seconds_disp} = display_time;

  // ---------------
  // Unused Outputs
  // ---------------

  assign minutes_disp[6] = 1'b0;

  assign led = 10'b0;

  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

endmodule
