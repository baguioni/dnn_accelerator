module pe(
	input [7:0] ifmap, filter,
	output reg [15:0] psum
);

	always @(*) begin
		psum = ifmap * filter;
		// $display("ifmap: %d, filter: %d, psum: %h", ifmap, filter, psum);
	end
endmodule
