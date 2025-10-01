`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.09.2025 04:37:20
// Design Name: 
// Module Name: bram_loader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ============================================
// BRAM Loader for Weights/Biases/Images
// ============================================
module bram_loader #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 784,
    parameter FILE       = "weights_l1.mem"
)(
    input  wire clk,
    input  wire [$clog2(DEPTH)-1:0] addr,
    output reg  [DATA_WIDTH-1:0] dout
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        $readmemh(FILE, mem);
    end

    always @(posedge clk) begin
        dout <= mem[addr];
    end
endmodule

