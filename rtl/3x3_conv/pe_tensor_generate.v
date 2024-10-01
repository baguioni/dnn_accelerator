module pe_tensor #(
    parameter N = 1
) (
    input clk, rst, wb_write_en,
    input [72 * N - 1:0] ifmap,
    input [72 * N - 1:0] filter,
    output [16 * N - 1:0] psumOut
);
    wire [144 * N - 1:0] psum;
    wire [72 * N - 1:0] filter_out;

    genvar w;

    generate
        for (w = 0; w < N; w = w + 1) begin: weight_buffer
            weight_buffer wb(
                .clk(clk),
                .rst(rst),
                .write_en(wb_write_en),
                .filter_in(filter[72 * (w + 1) - 1:72 * w]),
                .filter_out(filter_out[72 * (w + 1) - 1:72 * w])
            );
        end
    endgenerate

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: pe
            pe_kernel pe_k(
                .ifmap(ifmap[72 * (i + 1) - 1:72 * i]),
                .filter(filter_out[72 * (i + 1) - 1:72 * i]),
                .psum(psum[144 * (i + 1) - 1:144 * i])
            );
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < N; j = j + 1) begin: Accumulator
            accumulator acc(
                .psum(psum[144 * (j + 1) - 1:144 * j]),
                .psumOut(psumOut[16 * (j + 1) - 1:16 * j])
            );
        end
    endgenerate
endmodule