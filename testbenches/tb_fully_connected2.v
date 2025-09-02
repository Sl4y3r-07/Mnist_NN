`timescale 1ns/1ps
module tb_fully_connected2;
  reg clk, reset, start, in_valid;
  reg  [15:0] in_data;
  wire [15:0] out_data;
  wire out_valid, done;

  fully_connected2 dut (
    .clk(clk), .reset(reset), .start(start),
    .in_data(in_data), .in_valid(in_valid),
    .out_data(out_data), .out_valid(out_valid), .done(done)
  );

  // clock
  always #5 clk = ~clk;

  integer i;
  initial begin
    clk = 0; reset = 1; start = 0; in_valid = 0; in_data = 0;
    #20 reset = 0;

    // Start loading inputs
    start = 1;
    for (i=0; i<32; i=i+1) begin
      @(posedge clk);
      in_data = i;      // example test data
      in_valid = 1;
    end
    @(posedge clk); in_valid = 0;

    // Wait until computation done
    wait(done);
    $display("All 10 outputs computed.");

    #20 $finish;
  end

  // Print each neuron output
  always @(posedge clk) begin
    if (out_valid) begin
      $display("T=%0t | Neuron Out = %d", $time, $signed(out_data));
    end
  end
endmodule
