`timescale 1ns/1ps

module tb_fully_connected1;

  reg clk, reset, start;
  reg [15:0] in_data;
  reg in_valid;
  wire [15:0] out_data;
  wire out_valid, done;

  // DUT
  fully_connected1 dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .in_data(in_data),
    .in_valid(in_valid),
    .out_data(out_data),
    .out_valid(out_valid),
    .done(done)
  );

  // Clock
  always #5 clk = ~clk;

  integer i;

  initial begin
    clk = 0;
    reset = 1; start = 0; in_valid = 0; in_data = 0;
    #20 reset = 0;

    // Start loading inputs
    start = 1;
    for (i = 0; i < 784; i = i + 1) begin
      @(posedge clk);
      in_data = i;       // Example input values
      in_valid = 1;
    end
    @(posedge clk);
    in_valid = 0;

    // Wait for outputs
    wait(done);
    $display("All neurons computed. Last out_data = %d", $signed(out_data));

    #50 $finish;
  end

  always @(posedge clk) begin
    if (out_valid) begin
      $display("T=%0t | Neuron Output = %0d (0x%04x)", 
               $time, $signed(out_data), out_data);
    end
  end

endmodule
