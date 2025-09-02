`timescale 1ns/1ps
module tb_top_nn;

  reg clk, reset;
  wire [3:0] digit_out;
  wire valid_out;

  // DUT
  top_nn dut (
    .clk(clk),
    .reset(reset),
    .digit_out(digit_out),
    .valid_out(valid_out)
  );

  // Clock
  always #5 clk = ~clk;

  initial begin
    clk = 0; reset = 1;
    #20 reset = 0;

    // Simulation runs until prediction
    wait(valid_out);
    $display("Predicted Digit = %d at T=%0t", digit_out, $time);

    #50 $finish;
  end
endmodule
