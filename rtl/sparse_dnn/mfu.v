// ASSUME 8by8 mode
module mfu(
    input [8:0] a, w,
    output [15:0] o
);
    // Upper Left
    wire [3:0] p_ul_ul, p_ul_ur, p_ul_ll, p_ul_lr;
    wire [7:0] psum_ul;
    bitbrick bb_ul_ul(.a(a[7:6]), .w(7:6), .p(p_ul_ul));
    bitbrick bb_ul_ur(.a(a[7:6]), .w(5:4), .p(p_ul_ur));
    bitbrick bb_ul_ll(.a(a[5:4]), .w(7:6), .p(p_ul_ll));
    bitbrick bb_ul_lr(.a(a[5:4]), .w(5:4), .p(p_ul_lr));
    assign psum_ul = {{p_ul_ul << 2} + {p_ul_ur} + {p_ul_ll << 4} + {p_ul_lr << 2}};

    // Upper Right
    wire [3:0] p_ur_ul, p_ur_ur, p_ur_ll, p_ur_lr;
    wire [7:0] psum_ur;
    bitbrick bb_ur_ul(.a(a[7:6]), .w(3:2), .p(p_ur_ul));
    bitbrick bb_ur_ur(.a(a[7:6]), .w(1:0), .p(p_ur_ur));
    bitbrick bb_ur_ll(.a(a[5:4]), .w(3:2), .p(p_ur_ll));
    bitbrick bb_ur_lr(.a(a[5:4]), .w(1:0), .p(p_ur_lr));
    assign psum_ur = {{p_ur_ul << 2} + {p_ur_ur} + {p_ur_ll << 4} + {p_ur_lr << 2}};

    // Lower Left
    wire [3:0] p_ll_ul, p_ll_ur, p_ll_ll, p_ll_lr;
    wire [7:0] psum_ll;
    bitbrick bb_ll_ul(.a(a[3:2]), .w(7:6), .p(p_ll_ul));
    bitbrick bb_ll_ur(.a(a[3:2]), .w(5:4), .p(p_ll_ur));
    bitbrick bb_ll_ll(.a(a[1:0]), .w(7:6), .p(p_ll_ll));
    bitbrick bb_ll_lr(.a(a[1:0]), .w(5:4), .p(p_ll_lr));
    assign psum_ll = {{p_ll_ul << 2} + {p_ll_ur} + {p_ll_ll << 4} + {p_ll_lr << 2}};

    // Lower Right
    wire [3:0] p_lr_ul, p_lr_ur, p_lr_ll, p_lr_lr;
    wire [7:0] psum_lr;
    bitbrick bb_lr_ul(.a(a[3:2]), .w(3:2), .p(p_lr_ul));
    bitbrick bb_lr_ur(.a(a[3:2]), .w(1:0), .p(p_lr_ur));
    bitbrick bb_lr_ll(.a(a[1:0]), .w(3:2), .p(p_lr_ll));
    bitbrick bb_lr_lr(.a(a[1:0]), .w(1:0), .p(p_lr_lr));
    assign psum_lr = {{p_lr_ul << 2} + {p_lr_ur} + {p_lr_ll << 4} + {p_lr_lr << 2}};

    assign o = {{psum_ul << 4} + {psum_ur} + {psum_ll << 8} + {psum_lr << 4}};
endmodule