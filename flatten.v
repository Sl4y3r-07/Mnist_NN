// flatten.v
module flatten(
    input         clk,
    input         reset,
    input         start,          // start loading image
    output reg [15:0] pixel_out,   // Q15 pixel output
    output reg    pixel_valid,     // high when pixel_out is valid
    output reg    done             // high for one cycle after last pixel
);

//  reg signed [15:0] img_mem [0:783]; 
//  integer addr;
  
  localparam IMG_DEPTH = 784;
  reg [$clog2(IMG_DEPTH)-1:0] addr;
  wire [15:0] bram_dout;

  
  bram_loader #(
      .DATA_WIDTH(16),
      .DEPTH(IMG_DEPTH),
      .FILE("image.mem")
  ) U_img_bram (
      .clk(clk),
      .addr(addr),
      .dout(bram_dout)
  );
  
//  initial begin
//    $readmemh("image.mem", img_mem);
//    $display("image.mem loaded into flatten.v");
//    $display("First three values are: 0x%0h, 0x%0h, 0x%0h", img_mem[0], img_mem[1], img_mem[2]);
//  end

  reg running;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    addr <= 0;
    running <= 0;
    pixel_out <= 0;
    pixel_valid <= 0;
    done <= 0;
  end else begin
    if (start && !running) begin
      // start new run
      running <= 1;
      addr <= 0;
      done <= 0;
    end else if (running) begin
      if (addr < IMG_DEPTH-1) begin
          pixel_out   <= bram_dout;
        pixel_valid <= 1;
        done <= 0;
        $display("[%0t] Flatten: Pixel[%0d] = 0x%0h", $time, addr, bram_dout);
        addr <= addr + 1;
      end else if (addr == 783) begin
        pixel_out  <= bram_dout;
        pixel_valid <= 1;
        done <= 1;
        $display("[%0t] Flatten: Pixel[%0d] = 0x%0h (last pixel) -> DONE asserted", $time, addr, bram_dout);
        running <= 0;   
      end
    end else begin
      pixel_valid <= 0;
      done <= 0;
    end
  end
end

endmodule
