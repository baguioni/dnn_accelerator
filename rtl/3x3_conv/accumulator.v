module accumulator(
    input clk,
    input [143:0] psum,
    output reg [15:0] psumOut
);

    always @(posedge clk) begin
        psumOut = psum[15:0] + psum[31:16] + psum[47:32] + psum[63:48] + psum[79:64] + psum[95:80] + psum[111:96] + psum[127:112] + psum[143:128];
    end

endmodule
