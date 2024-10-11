// Byte-Addressable Buffer
// AFAIK Synthesis tool can map this to a 2-D structure in memory
module ba_buffer #(
    parameter DataWidth = 8,
    parameter Width = 5,
    parameter Depth = 5,
    parameter AddrWidth = $clog2(Width*Depth)
) (
    input clk, writeEn, 
    input [DataWidth-1:0] dataIn,
    input [AddrWidth-1:0] writeAddr,
    input [AddrWidth-1:0] readAddr,
    output [DataWidth-1:0] dataOut,
);
    reg [DataWidth-1:0] buffer [0:Depth-1];

    initial begin
        $readmemh("buffer.mem", buffer);
    end

    // Read data
    always @(posedge clk) begin
        dataOut <= buffer[readAddr];
    end

    // Write data
    always @(posedge clk) begin
        if (writeEn) begin
            buffer[writeAddr] <= dataIn;
        end
    end

endmodule