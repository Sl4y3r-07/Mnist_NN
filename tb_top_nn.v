`timescale 1ns/1ps
module tb_top_nn;

  reg clk, reset;
  wire [3:0] digit_out;
  wire valid_out;
  integer i;


  top_nn dut (
    .clk(clk),
    .reset(reset),
    .digit_out(digit_out),
    .valid_out(valid_out)
  );

//initial begin
//  $dumpfile("waves.vcd"); 
//  $dumpvars(0, tb_top_nn);  
//end
 

  always #5 clk = ~clk;

  initial begin
    clk = 0; reset = 1;
    #20 reset = 0;

    wait(valid_out);
    
    $display("Predicted Digit = %d at T=%0t", digit_out, $time);
    
    for (i = 0; i < 300; i = i + 1) begin
       @(posedge clk);
     end

     $display("Observation complete. Ending simulation.");

    $finish;
  end
endmodule
