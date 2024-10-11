module accumulator #(
    parameter Size = 9,
    parameter DataWidth = 8,
    parameter PsumWidth = DataWidth * 2
)(
    input wire clk,
    input wire [Size*PsumWidth-1:0] psum,
    output reg [PsumWidth-1:0] psumOut
);

    integer i;
    reg [PsumWidth-1:0] sum_acc;

    always @(posedge clk) begin
        sum_acc = 0;
        for (i = 0; i < Size; i = i + 1) begin
            sum_acc = sum_acc + psum[(i+1)*PsumWidth-1 -: PsumWidth];
        end
        psumOut <= sum_acc;
    end

endmodule
