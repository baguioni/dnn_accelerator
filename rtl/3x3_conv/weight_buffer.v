module weight_buffer(
    input clk, rst, write_en,
    input [71:0] filter_in,
    output [71:0] filter_out
);

    reg [71:0] filter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            filter <= 0;
        end else if (write_en) begin
            filter <= filter_in;
        end
    end

    assign filter_out = filter;

endmodule