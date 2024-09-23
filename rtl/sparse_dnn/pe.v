/*
each PE gets 1 activation and n weights

For 8x8 mode:
    weights are replicated as such: {4{w}}

For 4x4 mode:
    weights are replicated as such: {2{w[15:8]}, 2{w[7:0]}}
*/

module pe(
    parameter MFU_COUNT = 4;
    input [7:0] a, 
    input [MFU_COUNT*32-1:0] w,
    output [MFU_COUNT*64-1:0] o
);


    genvar i;

    generate
        for (i = 0; i < MFU_COUNT; i = i + 1) begin : mfu_inst
            mfu u_mfu (
                .a(a[7:0]),
                .w(w[i*32 +: 32]),
                .o(o[i*64 +: 64])
            );
        end
    endgenerate

endmodule