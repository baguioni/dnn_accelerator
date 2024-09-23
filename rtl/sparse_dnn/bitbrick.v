module bitbrick(
    input [1:0] a, w,
    input [1:0] sel,
    output reg [3:0] p
);
    wire [3:0] unsigned_mult_result;
    wire [3:0] signed_mult_result;
    wire [3:0] shifted_A;
    wire [3:0] adder_result;
    reg [3:0] mux_result;

    localparam _signed_unsigned = 2'b10;
    localparam _unsigned = 2'b01;
    localparam _signed = 2'b00;

    // 2-bit unsigned multiplier
    assign unsigned_mult_result = (a[1] * w[1] << 2) + (a[1] * w[0] << 1) + (a[0] * w[1] << 1) + (a[0] * w[0]);

    // 2-bit signed multiplier
    assign signed_mult_result = (a[1] * w[1] << 2) - (a[1] * w[0] << 1) - (a[0] * w[1] << 1) + (a[0] * w[0]);;

    always @(*) begin
        
        case (sel)
            _signed: begin
                p = signed_mult_result;
            end
            _unsigned: begin
                p = unsigned_mult_result;
            end
            _signed_unsigned: begin
                case (w[1])
                    1'b1: mux_result = {a, 2'b00};
                    1'b0: mux_result = 4'd0;
                endcase
                p = mux_result + unsigned_mult_result; // it works with unsigned but not with signed ??
            end
        endcase
    end

endmodule