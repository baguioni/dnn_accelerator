module top # (
    parameter Width = 9,
    parameter Height = 4,
    parameter Size = 9,
    parameter DataWidth = 8,
    parameter PsumWidth = 16
) (
    input clk, rst, readEn,
    output [PsumWidth-1:0] psumOut
);
    wire [2*Size*DataWidth-1:0] psum;
    wire [Size*DataWidth-1:0] ifmap;
    wire [Size*DataWidth-1:0] filter;

    pe_engine #(
        .Size(Size)
    ) pe_engine_inst (
        .clk(clk),
        .ifmap(ifmap),
        .filter(filter),
        .psum(psum)
    );

    accumulator #(
        .Size(Size),
        .PsumWidth(PsumWidth)
    ) accumulator_inst (
        .clk(clk),
        .psum(psum),
        .psumOut(psumOut)
    );

 // Add routers and buffers here

endmodule