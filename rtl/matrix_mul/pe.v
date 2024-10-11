module pe(
	input clk,
	input [7:0] ifmap, filter,
	output reg [15:0] psum
);

	always @(posedge clk) begin
		psum <= ifmap * filter;
		$display("ifmap: %d, filter: %d, psum: %d", ifmap, filter, psum);
	end
endmodule
