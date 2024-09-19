//  In a cycle, each PE is assigned with an individual activation which is shared by all of its MFUs.
module pe(
    parameter MFU_COUNT = 4;
    input [7:0] a, 
    input [MFU_COUNT*8-1:0] w,
    output [MFU_COUNT*16-1:0] o
);

    genvar i;

    generate
        for (i = 0; i < MFU_COUNT; i = i + 1) begin : mfu_inst
            mfu u_mfu (
                .a(a),
                .w(w[i*8 +: 8]),
                .o(o[i*16 +: 16])
            );
        end
    endgenerate

endmodule