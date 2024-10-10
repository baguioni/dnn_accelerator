// Word-Addressable Buffer
// Assume ifmap is row-major
module wa_buffer #(
    parameter Width = 5, // number of words (8-bit) in a line 
    parameter Depth = 5,
    parameter AddrWidth = $clog2(Depth)
) (
    input clk, writeEn, 
    input [Width*8-1:0] dataIn,
    input [AddrWidth-1:0] writeAddr,
    input [AddrWidth-1:0] readAddr,
    output [Width*8-1:0] dataOut,
);
    reg [Width*8-1:0] buffer [0:Depth-1];

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