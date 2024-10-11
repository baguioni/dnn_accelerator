module memory_top (
    input clk, rst, routeEn, writeEn,
    input [AddrWidth-1:0] writeAddr, startAddr,
    input [DataWidth-1:0] dataIn, // Data to buffer
    output finished,
    output [MaxWidth*DataWidth-1:0] dataOut // Data from router

);
    localparam MaxWidth = 9;
    localparam Depth = 32;
    localparam DataWidth = 8;
    localparam AddrWidth = $clog2(Depth);

    wire readEn;
    wire [AddrWidth-1:0] readAddr;
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

    router #(
        .MaxWidth(MaxWidth),
        .Depth(Depth),
        .DataWidth(DataWidth)
    ) router_inst (
        .clk(clk),
        .rst(rst),
        .routeEn(routeEn),
        .startAddr(startAddr),
        .dataIn(bufferOut),
        .readEn(readEn),
        .readAddr(readAddr),
        .dataOut(dataOut),
        .finished(finished)
    );
endmodule