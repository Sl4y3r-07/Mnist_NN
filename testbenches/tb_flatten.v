`timescale 1ns/1ps

module tb_flatten;

  reg clk, reset, start;
  wire [15:0] pixel_out;
  wire pixel_valid, done;

  // DUT instance
  flatten dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .pixel_out(pixel_out),
    .pixel_valid(pixel_valid),
    .done(done)
  );

  // Clock generator (10 ns period)
  always #5 clk = ~clk;

  initial begin
    // Init
    clk   = 0;
    reset = 1;
    start = 0;
    #20;
    reset = 0;

    // Start streaming
    #10 start = 1;

    // Run for some time to capture outputs
    #200 $finish;
  end

  // Monitor first few pixels
  integer count = 0;
  always @(posedge clk) begin
    if (pixel_valid) begin
      $display("T=%0t | pixel[%0d] = %0d (0x%04x)", 
               $time, count, $signed(pixel_out), pixel_out);
      count = count + 1;
      if (count == 5) begin
        $display("Displayed first 5 pixels, stopping.");
        $finish;
      end
    end
  end

endmodule
