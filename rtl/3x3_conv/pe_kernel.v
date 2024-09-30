module pe_kernel(
    input [71:0] ifmap,
    input [71:0] filter,
    output [143:0] psum
);

    pe pe0( .ifmap(ifmap[71:64]), .filter(filter[71:64]), .psum(psum[143:128]));
    pe pe1( .ifmap(ifmap[63:56]), .filter(filter[63:56]), .psum(psum[127:112]));
    pe pe2( .ifmap(ifmap[55:48]), .filter(filter[55:48]), .psum(psum[111:96]));
    pe pe3( .ifmap(ifmap[47:40]), .filter(filter[47:40]), .psum(psum[95:80]));
    pe pe4( .ifmap(ifmap[39:32]), .filter(filter[39:32]), .psum(psum[79:64]));
    pe pe5( .ifmap(ifmap[31:24]), .filter(filter[31:24]), .psum(psum[63:48]));
    pe pe6( .ifmap(ifmap[23:16]), .filter(filter[23:16]), .psum(psum[47:32]));
    pe pe7( .ifmap(ifmap[15:8]), .filter(filter[15:8]), .psum(psum[31:16]));
    pe pe8( .ifmap(ifmap[7:0]), .filter(filter[7:0]), .psum(psum[15:0]));

endmodule