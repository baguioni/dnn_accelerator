module top(
    input clk, rst, state,
    input [71:0] ifmap_in, filter_in,
    output [15:0] psumOut
);

    wire wb_write_en;
    wire [71:0] ifmap_out, filter_out;

    input_router ir(
        .clk(clk),
        .rst(rst),
        .state(state),
        .wb_write_en(wb_write_en),
        .ifmap_in(ifmap_in),
        .filter_in(filter_in),
        .ifmap_out(ifmap_out),
        .filter_out(filter_out)
    );

    pe_tensor pe_t(
        .clk(clk),
        .rst(rst),
        .wb_write_en(wb_write_en),
        .ifmap(ifmap_out),
        .filter(filter_out),
        .psumOut(psumOut)
    );
endmodule
