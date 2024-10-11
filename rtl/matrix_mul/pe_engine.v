module pe_engine # (
    parameter Size = 9,
    parameter DataWidth = 8
) (
    input wire clk,
    input wire [Size*DataWidth-1:0] ifmap,
    input wire [Size*DataWidth-1:0] filter,
    output reg [2*Size*DataWidth-1:0] psum
);
    genvar i;
    generate
        for (i = 0; i < Size; i = i + 1) begin : pe_generation
            wire [7:0] ifmap_slice = ifmap[(i+1)*DataWidth-1 -: DataWidth];
            wire [7:0] filter_slice = filter[(i+1)*DataWidth-1 -: DataWidth];
            wire [15:0] psum_slice;

            pe pe_inst (
                .clk(clk),
                .ifmap(ifmap_slice),
                .filter(filter_slice),
                .psum(psum_slice)
            );

            always @(posedge clk) begin
                psum[(i+1)*16-1 -: 16] <= psum_slice;
            end
        end
    endgenerate
endmodule
