// Fixed-Frequency Fixed-Duty PWM Generator

// Output remains High for (D)UTY_CYCLES / PERIOD/CYCLES)% of a Period
// PERIOD_CYCLES determines the Number of Clock Cycles per Period
// DUTY_CYCLES determines the Number of Cycles per Duty Cycle (Length of Time to Output High)

`timescale 1ns / 1ps

module pwm_generator #(
    // Number of Clock Cycles in One PWM Period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of Clock Cycles for which Output is High
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  // Determines the width of the variable count
  localparam int CountWidth = $clog2(PERIOD_CYCLES);

  logic [CountWidth - 1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),  // Feed in the Max Count for the Module
      .WIDTH(CountWidth)  // Feed in the Width of the Max COunt
  ) u_mod_n_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),  // Always Enable
      .count(count)
  );

  always_comb begin
    if (DUTY_CYCLES >= PERIOD_CYCLES) begin
      pwm_out = 1'b1;
    end else begin
      pwm_out = count < CountWidth'(DUTY_CYCLES);
    end
  end

endmodule
