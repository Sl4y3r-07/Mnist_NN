`timescale 1ns/1ps
module tb_argmax;

  reg clk, reset, start, in_valid;
  reg  [15:0] in_data;
  wire [3:0]  max_index;
  wire done;

  // DUT
  argmax dut (
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .in_valid(in_valid),
    .start(start),
    .max_index(max_index),
    .done(done)
  );

  // Clock gen
  always #5 clk = ~clk;

  integer i;
  reg signed [15:0] test_data [0:9];  // 10 test inputs

  initial begin
    clk = 0; reset = 1; start = 0; in_valid = 0; in_data = 0;

    test_data[0] = 100;
    test_data[1] = -50;
    test_data[2] = 200;
    test_data[3] = 500;   // maximum
    test_data[4] = 123;
    test_data[5] = -300;
    test_data[6] = 250;
    test_data[7] = 4000;
    test_data[8] = 50;
    test_data[9] = 10;

    #20 reset = 0;
    #10 start = 1;

    for (i=0; i<10; i=i+1) begin
      @(posedge clk);
      in_data  = test_data[i];
      in_valid = 1;
    end
    @(posedge clk);
    in_valid = 0;

    wait(done);
    $display("T=%0t | Max Index = %d", $time, max_index);

    #20 $finish;
  end
endmodule
