module relu (
    input [15:0] din_relu,  
    output [15:0] dout_relu 
);

assign dout_relu = (din_relu[15] == 0) ? din_relu : 16'd0;

endmodule