`timescale 1ns/1ps

module tb_relu;

  reg clk;
  reg reset;
  reg signed [15:0] in_data;
  reg in_valid;
  wire signed [15:0] out_data;
  wire out_valid;

  // Instantiate the DUT
  relu dut (
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .in_valid(in_valid),
    .out_data(out_data),
    .out_valid(out_valid)
  );

  // Clock generator: 10ns period
  always #5 clk = ~clk;

  initial begin
    // Initialize
    clk = 0;
    reset = 1;
    in_data = 0;
    in_valid = 0;

    // Apply reset
    #20 reset = 0;

    // ---- Test 1: Positive input ----
    @(negedge clk);
    in_data = 16'sd1000;  // +1000
    in_valid = 1;
    @(negedge clk);
    in_valid = 0;
    #20;

    // ---- Test 2: Negative input ----
    @(negedge clk);
    in_data = -16'sd500;  // -500
    in_valid = 1;
    @(negedge clk);
    in_valid = 0;
    #20;

    // ---- Test 3: Zero input ----
    @(negedge clk);
    in_data = 16'sd0;     // 0
    in_valid = 1;
    @(negedge clk);
    in_valid = 0;
    #20;

    // Finish
    $finish;
  end

  // Display results
  initial begin
    $monitor("Time=%0t | in_data=%d | in_valid=%b | out_data=%d | out_valid=%b",
             $time, in_data, in_valid, out_data, out_valid);
  end

endmodule
