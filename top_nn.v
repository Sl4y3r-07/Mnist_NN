// top_nn.v
module top_nn(
    input         clk,
    input         reset,
    // Control or I/O pins can be added here
    output [3:0]  digit_out,    // final predicted digit (0-9)
    output        valid_out     // high when digit_out is valid
);
  // Internal wires connecting modules
  wire [15:0] pixel;
  wire        pix_valid, pix_done;
  reg         flatten_start;

  wire [15:0] fc1_out;
  wire        fc1_valid, fc1_done;
  reg         fc1_start;

  wire [15:0] relu_out;
  wire        relu_valid;

  wire [15:0] fc2_out;
  wire        fc2_valid, fc2_done;
  reg         fc2_start;

  wire [3:0]  arg_index;
  wire        arg_done;
  reg         arg_start;

  // Instantiate Flatten
  flatten U_flat(
    .clk(clk), .reset(reset), .start(flatten_start),
    .pixel_out(pixel), .pixel_valid(pix_valid), .done(pix_done)
  );

  // Instantiate Fully Connected Layer 1
  fully_connected1 U_fc1(
    .clk(clk), .reset(reset), .start(fc1_start),
    .in_data(pixel), .in_valid(pix_valid),
    .out_data(fc1_out), .out_valid(fc1_valid),
    .done(fc1_done)
  );

  // Instantiate ReLU
  relu U_relu(
    .clk(clk), .reset(reset),
    .in_data(fc1_out), .in_valid(fc1_valid),
    .out_data(relu_out), .out_valid(relu_valid)
  );

  // Instantiate Fully Connected Layer 2
  fully_connected2 U_fc2(
    .clk(clk), .reset(reset), .start(fc2_start),
    .in_data(relu_out), .in_valid(relu_valid),
    .out_data(fc2_out), .out_valid(fc2_valid),
    .done(fc2_done)
  );

  // Instantiate Argmax
  argmax U_arg(
    .clk(clk), .reset(reset), .start(arg_start),
    .in_data(fc2_out), .in_valid(fc2_valid),
    .max_index(arg_index), .done(arg_done)
  );

  // Output assignments
  assign digit_out = arg_index;
  assign valid_out = arg_done;

  // FSM to sequence the operations
  reg [2:0] state;
  localparam IDLE   = 3'd0,
             LOAD   = 3'd1,
             DO_FC1 = 3'd2,
             DO_FC2 = 3'd3,
             DO_ARG = 3'd4,
             DONE   = 3'd5;

    always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      flatten_start <= 0; 
      fc1_start <= 0; 
      fc2_start <= 0; 
      arg_start <= 0;
    end else begin
      case (state)
        IDLE: begin
          flatten_start <= 1;  // keep high until pix_done
          $display("[%0t] Starting Flatten", $time);
          state <= LOAD;
        end

        LOAD: begin
          flatten_start <= 1;  // keep asserting start
          if (pix_done) begin
            flatten_start <= 0; // release after done
            fc1_start <= 1;
            $display("[%0t] Flatten done, starting FC1", $time);
            state <= DO_FC1;
          end
        end

        DO_FC1: begin
          fc1_start <= 1;  // keep high until fc1_done
          fc2_start <= 1;
          if (fc1_done) begin
            fc1_start <= 0;
            fc2_start <= 1;
            $display("[%0t] FC1 done, starting FC2", $time);
            state <= DO_FC2;
          end
        end

        DO_FC2: begin
          fc2_start <= 1;  // keep high until fc2_done
          arg_start <= 1;
          if (fc2_done) begin
            fc2_start <= 0;
            arg_start <= 1;
            $display("[%0t] FC2 done, starting Argmax", $time);
            state <= DO_ARG;
          end
        end

        DO_ARG: begin
          arg_start <= 1;  // keep high until arg_done
          if (arg_done) begin
            arg_start <= 0;
            $display("[%0t] Argmax done, digit=%0d", $time, arg_index);
            state <= DONE;
          end
        end

        DONE: begin
          // stay here with outputs stable
          state <= DONE;
        end
      endcase
    end
  end
endmodule
