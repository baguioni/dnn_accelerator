module bitbrick(
    input [1:0] a, w,
    output [3:0] p
);
    // 2-bit unsigned multiplier
    assign psum = a * w;
endmodule