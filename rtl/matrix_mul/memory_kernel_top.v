module memory_kernel_top (
    input clk, rst, routeEn, writeEn,
    input [AddrWidth-1:0] writeAddr, startAddr,
    input [DataWidth-1:0] dataIn, // Data to buffer
    input [AddrWidth-1:0] inputWidth, // Size of input
    output finished,
    output [3:0] state,
    output [MaxWidth*DataWidth-1:0] dataOut // Data from router
);
    localparam MaxWidth = 9;
    localparam Depth = 32;
    localparam DataWidth = 8;
    localparam AddrWidth = $clog2(Depth);

    wire readEn;
    wire [AddrWidth-1:0] readAddr;
    wire [AddrWidth-1:0] lastReadAddr;
    wire [DataWidth-1:0] bufferOut;

    buffer #(
        .Depth(Depth),
        .DataWidth(DataWidth)
    ) buffer_inst (
        .clk(clk),
        .writeEn(writeEn),
        .readEn(readEn),
        .dataIn(dataIn),
        .writeAddr(writeAddr),
        .readAddr(readAddr),
        .dataOut(bufferOut)
    );

    router_kernel #(
        .MaxWidth(MaxWidth),
        .Depth(Depth),
        .DataWidth(DataWidth)
    ) router_inst (
        .clk(clk),
        .rst(rst),
        .routeEn(routeEn),
        .startAddr(startAddr),
        .dataIn(bufferOut),
        .inputWidth(inputWidth),
        .readEn(readEn),
        .state(state),
        .readAddr(readAddr),
        .lastReadAddr(lastReadAddr),
        .dataOut(dataOut),
        .finished(finished)
    );
endmodule