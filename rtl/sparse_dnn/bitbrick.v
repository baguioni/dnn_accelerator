module bitbrick(
    input [1:0] a, w,
    input sel,
    output reg [3:0] p
);
    wire [3:0] unsigned_mult_result;
    wire [3:0] signed_mult_result;
    wire [3:0] shifted_A;
    wire [3:0] adder_result;
    reg [3:0] mux_result;


    // 2-bit unsigned multiplier
    assign unsigned_mult_result = a * w;

    // 2-bit signed multiplier
    assign signed_mult_result = $signed(a) * $signed(w);

    // Shift A by 2 bits
    assign shifted_A = {a, 2'b00};

    always @(*) begin
        case (sel)
            1'b1: begin
                p = unsigned_mult_result;
            end
            1'b0: begin
                case (w[1])
                    1'b1: mux_result = shifted_A;
                    1'b0: mux_result = 4'd0;
                endcase
                p = mux_result + signed_mult_result;
            end
            default: p = 4'd0;
        endcase
    end

endmodule