// Fully connected layer: 32 -> 10
module fully_connected2(
    input             clk,
    input             reset,
    input      [15:0] in_data,
    input             in_valid,
    input             start,
    output reg [15:0] out_data,
    output reg        out_valid,
    output reg        done
);
  integer i;
  reg signed [15:0] in_mem [0:31];        // store 32 inputs
  reg signed [15:0] weight_mem [0:319];   // 10*32 weights
  reg signed [15:0] bias_mem   [0:9];      // 10 biases
  reg signed [31:0] acc;

  reg [6:0]  in_cnt;   // input counter
  reg [3:0]  neuron;   // neuron index 0..9
  reg        computing;

  // Load weights and biases from single files
  initial begin
    $readmemh("weights_l2.mem", weight_mem);  
    $readmemh("biases_l2.mem", bias_mem);    // 10 entries

    $display("weights_l2.mem loaded into fully_connected2.v");
    $display("biases_l2.mem loaded into fully_connected2.v");
    $display("First three values of weights_l2: 0x%0h, 0x%0h, 0x%0h", weight_mem[0], weight_mem[1], weight_mem[2]);
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      in_cnt    <= 0;
      neuron    <= 0;
      acc       <= 0;
      out_valid <= 0;
      done      <= 0;
      computing <= 0;
    end else if (start && !computing) begin
      // Load 32 inputs
      if (in_valid && in_cnt < 32) begin
        in_mem[in_cnt] <= in_data;
        in_cnt <= in_cnt + 1;
        $display("FC2 in_data= %0d", in_data);
   
      end
      if (in_cnt == 32) begin
        computing <= 1;
        in_cnt    <= 0;
        neuron    <= 0;
        acc       <= 0;
        out_valid <= 0;
        done      <= 0;
      end
    end else if (computing) begin
      if (in_cnt < 32) begin
        acc <= acc + in_mem[in_cnt] * weight_mem[neuron*32 + in_cnt];
        in_cnt <= in_cnt + 1;
        out_valid <= 0;
      end else begin
        acc      <= acc + (bias_mem[neuron] <<< 15);
        out_data <= acc[30:15];
        out_valid<= 1;
       
       $display("[%0t] FC2: Neuron[%0d] Output = 0x%0h", $time, neuron, acc[30:15]);
   
        acc    <= 0;
        in_cnt <= 0;
        neuron <= neuron + 1;

        if (neuron == 9) begin    // check here tooo 
          done      <= 1;
          computing <= 0;
        end
      end
    end else begin
      out_valid <= 0;
      done      <= 0;
    end
  end
endmodule
