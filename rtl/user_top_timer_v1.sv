// Timer Integration

// button[0] --> start/pause in normal mode, decrement in edit mode
// button[1] --> increment in edit mode
// button[2] --> enter/advance/exit edit mode

`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
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

  logic running = 1'b0;  // Stores whether or not timer is currently running down

  logic [2:0] mode_enable;
  logic edit_mode;

  // Allows for the transition to and from edit mode, as well as specific edit modes
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  assign edit_mode = |mode_enable;  // If any edit mode is selected, the timer is in edit mode

  logic rise_start_pause;

  // Turns a button press into a single pulse
  rising_edge_detector u_start_pause_edge (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise_start_pause)
  );

  logic inc_pulse;
  logic dec_pulse;

  // Used so if you hold a button down during edit, it skips through faster
  // One for increment and one for decrement
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  logic one_second_tick;
  logic timer_tick;
  logic timer_zero;

  // Generates the 1 Hz countdown tick
  // Only runs when running = 1, and not in edit mode and timer is not zero
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_one_second_tick (
      .clk (clk),
      .run (running && !edit_mode && !timer_zero),
      .tick(one_second_tick)
  );

  assign timer_tick = one_second_tick && running && !edit_mode && !timer_zero;

  logic [6:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic seconds_borrow;
  logic minutes_borrow;

  /* verilator lint_off UNUSED */
  logic hours_borrow;
  /* verilator lint_on UNUSED */

  assign timer_zero = (hours == 7'd0) && (minutes == 6'd0) && (seconds == 6'd0);

  // This section creates the coundown, with borrow used to decrement minutes when seconds reaches 0

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(timer_tick),
      .edit_mode(mode_enable[0]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(seconds_borrow),
      .edit_mode(mode_enable[1]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  // No borrow because it doesn't have a more significant number above it
  // Still needs an editable_countdown so you can set the hours
  editable_countdown #(
      .MAX  (23),
      .WIDTH(7)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(minutes_borrow),
      .edit_mode(mode_enable[2]),
      .inc(inc_pulse),
      .dec(dec_pulse),
      .count(hours),
      .borrow_out(hours_borrow)
  );

  logic finishing_tick;

  assign finishing_tick = timer_tick && (hours == 7'd0) && (minutes == 6'd0) && (seconds == 6'd1);

  always_ff @(posedge clk) begin
    if (edit_mode || finishing_tick) begin
      running <= 1'b0;
    end else if (rise_start_pause && !edit_mode) begin
      if (running) begin
        running <= 1'b0;
      end else if (!timer_zero) begin
        running <= 1'b1;
      end
    end
  end

  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_flash_pwm (
      .clk(clk),
      .rst(!edit_mode),
      .pwm_out(pwm_out)
  );

  // Creates the flashing for the currently selected field
  assign blank_seconds = mode_enable[0] && pwm_out;
  assign blank_minutes = mode_enable[1] && pwm_out;
  assign blank_hours = mode_enable[2] && pwm_out;

  //Counters are sent directly to display outputs (minutes and seconds are zero-extended)
  assign hours_disp = hours;
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  assign led = 10'b0;

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule
