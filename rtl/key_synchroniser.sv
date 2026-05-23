// Key Synchroniser

// Input key_n is asynchronous and active-low (whereas we use active high the entire project)
// Need to make it active-high (invert it) and synchronise it
// _n refers to active-low so we invert it with ~key_n
// Synchronise it by feeding it into two cascaded flip flows (as per the lectures)

`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active_low, asynchronous
    output logic [3:0] key_sync  // active-high, synchronouos
);

  logic [3:0] key_async;

  initial key_async = '0;
  initial key_sync = '0;

  always_ff @(posedge clk) begin
    key_async <= ~key_n;  // Invert and Feed into First Flip Flop
    key_sync  <= key_async;  // Feed into Second Flip Flop to Complete Synchronisation
  end

endmodule
