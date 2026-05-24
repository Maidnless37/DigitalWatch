// Up-Down Counter with Reset

`timescale 1ns / 1ps

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count = '0
);

  localparam logic [WIDTH - 1:0] Max = WIDTH'(MAX);  // Casts MAX to length WIDTH

  always_ff @(posedge clk) begin
    if (rst) begin  // Reset Counter to Zero
      count <= '0;
    end else if (enable) begin  // Only count if enable = 1

      // Count Up
      if (up) begin  // Count Uo
        if (count == Max) begin  // Wrap around at MAX
          count <= '0;
        end else begin  // Else increment the count
          count <= count + 1'b1;
        end
      end else begin  // Count Down
        if (count == '0) begin  // Wrap Around at Zero
          count <= Max;
        end else begin  // Else decrement the count
          count <= count - 1'b1;
        end
      end
    end
  end

endmodule
