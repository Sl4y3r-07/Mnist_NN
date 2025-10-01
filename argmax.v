// argmax.v
// Find index of maximum among 10 signed inputs
module argmax(
    input             clk,
    input             reset,
    input      [15:0] in_data,   
    input             in_valid,  // high when in_data is valid
    input             start,
    output reg [3:0]  max_index, // 0..9 predicted digit
    output reg        done
);
  reg signed [15:0] max_val;
  reg [3:0] count;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      max_val   <= 0;
      max_index <= 0;
      count     <= 0;
      done      <= 0;
    end else if (start) begin
      if (in_valid) begin
        if (count == 0) begin
          max_val   <= in_data;
          max_index <= 0;
          count     <= 1;
          $display("[%0t] Argmax: Init value = 0x%0h (index 0)", $time, in_data);
        end else begin
          // Compare and update
          if ($signed(in_data) > $signed(max_val)) begin
            max_val   <= in_data;
            max_index <= count;
            $display("[%0t] Argmax: New Max = %0d at Index %0d", $time, in_data, count);
          end
          count <= count + 1;
          if (count == 9) begin
             done <= 1;
            $display("[%0t] Argmax DONE: Final Max = %0d at Index %0d", $time, max_val, max_index);
//            count <= 9;
            
          end
        end
      end
  end
  end
endmodule
