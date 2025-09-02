// fully_connected1.v
// Fully connected layer: 784 inputs -> 128 outputs (Q15 fixed-point)

module fully_connected1(
    input              clk,
    input              reset,
    input              start,         
    input      [15:0]  in_data,       
    input              in_valid,      
    output reg [15:0]  out_data,      
    output reg         out_valid,     
    output reg         done           
);

  integer i;
  reg signed [15:0] in_mem [0:783];        // 784 input pixels
  reg signed [15:0] weight_mem [0:32*784-1]; // Flattened weights
  reg signed [15:0] bias_mem   [0:31];    // Biases

  reg signed [31:0] acc;  
  reg [9:0]  in_cnt;    
  reg [6:0]  neuron;    
  reg        computing;

  // Load weights and biases (flattened)
  initial begin
    $readmemh("weights_l1.mem", weight_mem); // contains 128*784 entries
    $readmemh("biases_l1.mem", bias_mem);      // contains 128 entries

    $display("weights_l1.mem loaded into fully_connected1.v");
    $display("biases_l1.mem loaded into fully_connected1.v");
    $display("First three values of weights_l1: 0x%0h, 0x%0h, 0x%0h", weight_mem[0], weight_mem[1], weight_mem[2]);
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      in_cnt    <= 0;
      neuron    <= 0;
      acc       <= 0;
      out_data  <= 0;
      out_valid <= 0;
      done      <= 0;
      computing <= 0;
    end 
    else if (start && !computing) begin
      // LOAD inputs
      if (in_valid && in_cnt < 784) begin
        in_mem[in_cnt] <= in_data;
        in_cnt <= in_cnt + 1;
      end
      if (in_cnt == 784) begin
        // Start computing
        computing <= 1;
        in_cnt    <= 0;
        neuron    <= 0;
        acc       <= 0;
      end
    end 
    else if (computing) begin
      // Compute one neuron
      if (in_cnt < 784) begin
        acc <= acc + in_mem[in_cnt] * weight_mem[neuron*784 + in_cnt];
        in_cnt <= in_cnt + 1;
        out_valid <= 0;
      end 
      else begin
        // Add bias and output
        acc <= acc + (bias_mem[neuron] << 15);
        out_data <= acc[30:15];   // Q30 → Q15
        out_valid <= 1;
        
        $display("[%0t] FC1: Neuron[%0d] Output = 0x%0h", $time, neuron, acc[30:15]);

        // Prepare next neuron
        acc    <= 0;
        in_cnt <= 0;
        neuron <= neuron + 1;

        if (neuron == 31) begin    // need to look for this 
          done      <= 1;
          computing <= 0;
        end 
      end
    end 
    else begin
      out_valid <= 0;
      done <= 0;
    end
  end
endmodule
