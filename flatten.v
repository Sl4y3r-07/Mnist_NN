// flatten.v
// Read 28x28 image from .mem file and output pixels sequentially
module flatten(
    input         clk,
    input         reset,
    input         start,          // start loading image
    output reg [15:0] pixel_out,   // Q15 pixel output
    output reg    pixel_valid,     // high when pixel_out is valid
    output reg    done             // high for one cycle after last pixel
);
  // 28*28 = 784 pixels
  reg signed [15:0] img_mem [0:783]; 
  integer addr;
  
  // Initialize image memory from file (hex format, one value per line)
  initial begin
    $readmemh("image.mem", img_mem);
    $display("image.mem loaded into flatten.v");
    $display("First three values are: 0x%0h, 0x%0h, 0x%0h", img_mem[0], img_mem[1], img_mem[2]);
  end

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
      if (addr < 783) begin
        pixel_out  <= img_mem[addr];
        pixel_valid <= 1;
        done <= 0;
        $display("[%0t] Flatten: Pixel[%0d] = 0x%0h", $time, addr, img_mem[addr]);
        addr <= addr + 1;
      end else if (addr == 783) begin
        pixel_out  <= img_mem[addr];
        pixel_valid <= 1;
        done <= 1;
        $display("[%0t] Flatten: Pixel[%0d] = %0h (last pixel) -> DONE asserted",
                  $time, addr, img_mem[addr]);
        running <= 0;   
      end
    end else begin
      pixel_valid <= 0;
      done <= 0;
    end
  end
end

endmodule
