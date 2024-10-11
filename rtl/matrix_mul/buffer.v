// Will handle cases when write and read are enabled at the same time in the future
// Byte-addressable memory
// Assume each row stores a byte
module buffer #(
    parameter Depth = 32,
    parameter DataWidth = 8,
    parameter AddrWidth = $clog2(Depth)
    // parameter FileName = "weights.mem"
)(
    input clk, writeEn, readEn,
    input [DataWidth-1:0] dataIn,
    input [AddrWidth-1:0] writeAddr,
    input [AddrWidth-1:0] readAddr,
    output [DataWidth-1:0] dataOut
);

    reg [DataWidth-1:0] buffer [0:Depth-1];
    reg [DataWidth-1:0] tempDataOut;

    // initial begin
    //     $readmemh(FileName, buffer);
    // end

    // Read data
    always @(posedge clk) begin
        if (readEn) begin
            // $display("dataOut: %h | readAddr: %h", buffer[readAddr], readAddr);
            tempDataOut <= buffer[readAddr];
        end
    end

    assign dataOut = tempDataOut;

    // Write data
    always @(posedge clk) begin
        if (writeEn) begin
            $display("dataIn: %h | writeAddr: %h", dataIn, writeAddr);
            buffer[writeAddr] <= dataIn;
        end
    end

endmodule