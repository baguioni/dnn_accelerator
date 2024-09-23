/*
2x2 mode: one 2-bit activation and 16 2-bit weights
4x4 mode: one 4-bit activation and four 4-bit weights
8x8 mode: one 8-bit activation and one 8-bit weights
to resolve varying bitwitdths, we perform bit replication
this implies we have to support the maximum input and output bitwidth for each mode
this replication is done in higher level modules

The weights are distributed as such:
    [31:30, 29:28, 27:26, 25: 24]
    [23:22, 21:20, 19:18, 17:16]
    [15:14, 13:12, 11:10, 9:8]
    [7:6, 5:4, 3:2, 1:0]

For 2x2 mode:
    [w0, w1, w2, w3]
    [w4, w5, w6, w7]
    [w8, w9, w10, w11]
    [w12, w13, w14, w15]

For 4x4 mode:
    [w0[3:2], w0[1:0], w1[3:2], w1[1:0]]
    [w0[3:2], w0[1:0], w1[3:2], w1[1:0]]
    [w2[3:2], w2[1:0], w3[3:2], w3[1:0]]
    [w2[3:2], w2[1:0], w3[3:2], w3[1:0]]

For 8x8 mode:
    [w0[7:6], w0[5:4], w0[3:2], w0[1:0]]
    [w0[7:6], w0[5:4], w0[3:2], w0[1:0]]
    [w0[7:6], w0[5:4], w0[3:2], w0[1:0]]
    [w0[7:6], w0[5:4], w0[3:2], w0[1:0]]

The activations bit spliced along the column and passed along the rows.

*/


module mfu(
    input [7:0] a,
    input [31:0] w,
    input [2:0] mode, // 2x2, 4x4, 8x8
    output reg [63:0] o
);
    localparam _signed_unsigned = 2'b10;
    localparam _unsigned = 2'b01;
    localparam _signed = 2'b00;

    localparam _2bx2b = 0;
    localparam _4bx4b = 1;
    localparam _8bx8b = 2;

    // Upper Left
    wire [3:0] p_ul_ul, p_ul_ur, p_ul_ll, p_ul_lr;
    wire [7:0] psum_ul;
    bitbrick ul_ul(.a(a[7:6]), .w(w[31:30]), .p(p_ul_ul), .sel(_unsigned));
    bitbrick ul_ur(.a(a[7:6]), .w(w[29:28]), .p(p_ul_ur), .sel(_signed_unsigned));
    bitbrick ul_ll(.a(a[5:4]), .w(w[23:22]), .p(p_ul_ll), .sel(_signed_unsigned));
    bitbrick ul_lr(.a(a[5:4]), .w(w[21:20]), .p(p_ul_lr), .sel(_signed));
    assign psum_ul = {{p_ul_lr, p_ul_ul} + {{p_ul_ur, 2'b00}} + {{p_ul_ll, 2'b00}}};

    // Upper Right
    wire [3:0] p_ur_ul, p_ur_ur, p_ur_ll, p_ur_lr;
    wire [7:0] psum_ur;
    bitbrick ur_ul(.a(a[7:6]), .w(w[27:26]), .p(p_ur_ul), .sel(_unsigned));
    bitbrick ur_ur(.a(a[7:6]), .w(w[25:24]), .p(p_ur_ur), .sel(_signed_unsigned));
    bitbrick ur_ll(.a(a[5:4]), .w(w[19:18]), .p(p_ur_ll), .sel(_signed_unsigned));
    bitbrick ur_lr(.a(a[5:4]), .w(w[17:16]), .p(p_ur_lr), .sel(_signed));
    assign psum_ur = {{p_ur_lr, p_ur_ul} + {{p_ur_ur, 2'b00}} + {{p_ur_ll, 2'b00}}};

    // Lower Left
    wire [3:0] p_ll_ul, p_ll_ur, p_ll_ll, p_ll_lr;
    wire [7:0] psum_ll;
    bitbrick ll_ul(.a(a[3:2]), .w(w[15:14]), .p(p_ll_ul), .sel(_unsigned));
    bitbrick ll_ur(.a(a[3:2]), .w(w[13:12]), .p(p_ll_ur), .sel(_signed_unsigned));
    bitbrick ll_ll(.a(a[1:0]), .w(w[7:6]), .p(p_ll_ll), .sel(_signed_unsigned));
    bitbrick ll_lr(.a(a[1:0]), .w(w[5:4]), .p(p_ll_lr), .sel(_signed));
    assign psum_ll = {{p_ll_lr, p_ll_ul} + {{p_ll_ur, 2'b00}} + {{p_ll_ll, 2'b00}}};

    // Lower Right
    wire [3:0] p_lr_ul, p_lr_ur, p_lr_ll, p_lr_lr;
    wire [7:0] psum_lr;
    bitbrick lr_ul(.a(a[3:2]), .w(w[11:10]), .p(p_lr_ul), .sel(_unsigned));
    bitbrick lr_ur(.a(a[3:2]), .w(w[9:8]), .p(p_lr_ur), .sel(_signed_unsigned));
    bitbrick lr_ll(.a(a[1:0]), .w(w[3:2]), .p(p_lr_ll), .sel(_signed_unsigned));
    bitbrick lr_lr(.a(a[1:0]), .w(w[1:0]), .p(p_lr_lr), .sel(_signed));
    assign psum_lr = {{p_lr_lr, p_lr_ul} + {{p_lr_ur, 2'b00}} + {{p_lr_ll, 2'b00}}};

    always @(*) begin
        case(mode)
            _2bx2b: o = {p_lr_lr, p_lr_ll, p_ll_lr, p_ll_ll, p_ll_ul, p_ll_ur, p_lr_ul, p_lr_ur, p_ur_lr, p_ur_ll, p_ul_lr, p_ul_ll, p_ur_ur, p_ur_ul, p_ul_ur, p_ul_ul};
            _4bx4b: o = {psum_ul, psum_ur, psum_ll, psum_lr}; // 32-bit output
            _8bx8b: o = {{psum_ul << 4} + {psum_ur} + {psum_ll << 8} + {psum_lr << 4}}; // 16-bit output
        endcase
    end
endmodule