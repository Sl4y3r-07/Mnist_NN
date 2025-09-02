`timescale 1ns/1ps

module tb_relu;
  reg  [15:0] din_relu;
  wire [15:0] dout_relu;
  
  wire signed [15:0] din_signed;
  wire signed [15:0] dout_signed;

  assign din_signed  = din_relu;
  assign dout_signed = dout_relu;

  relu dut (
    .din_relu(din_relu),
    .dout_relu(dout_relu)
  );

  initial begin
    // Monitor signals
    $monitor("T=%0t | din_relu=%d | dout_relu=%d",$time, din_signed, dout_signed);
    din_relu = 16'sd1000;
    #10;
    din_relu = -16'sd1110; 
    #10;
    din_relu = 16'sd0;
    #10;
    $finish;
  end

endmodule
