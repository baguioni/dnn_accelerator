module pe_tensor (
    input clk, rst, wb_write_en,
    input [71:0] ifmap,
    input [71:0] filter,
    output [15:0] psumOut
);
    wire [143:0] psum;
    wire [71:0] filter_out;

    weight_buffer wb(
        .clk(clk),
        .rst(rst),
        .write_en(wb_write_en),
        .filter_in(filter),
        .filter_out(filter_out)
    );

    pe_kernel pe_k(
        .clk(clk),
        .ifmap(ifmap),
        .filter(filter_out),
        .psum(psum)
    );

    accumulator acc(
        .clk(clk),
        .psum(psum),
        .psumOut(psumOut)
    );
endmodule
