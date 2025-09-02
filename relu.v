module relu(
    input         clk,
    input         reset,
    input  signed [15:0] in_data,
    input         in_valid,
    output reg signed [15:0] out_data,
    output reg    out_valid
);
  wire signed [15:0] relu_res = in_data[15] ? 16'sd0 : in_data;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out_data  <= 0;
      out_valid <= 0;
    end else if (in_valid) begin
      out_data  <= relu_res;
      out_valid <= 1'b1;
      $display("[%0t] ReLU: Input=%0d, Output=%0d",
               $time, $signed(in_data), $signed(relu_res));
    end else begin
      out_valid <= 1'b0;
    end
  end
endmodule
