module tb_bitbrick;
    reg [3:0] a, b;
    wire signed [3:0] p0, p1, p2, p3; 
    wire signed [7:0] product;

    localparam _signed_unsigned = 2'b10;
    localparam _unsigned = 2'b01;
    localparam _signed = 2'b00;

    bitbrick uut0 (.a(a[1:0]), .b(b[1:0]), .sel(_unsigned), .p(p0));  // Lower 2x2 bits - a
    bitbrick uut1 (.a(a[3:2]), .b(b[1:0]), .sel(_signed_unsigned), .p(p1));  // Upper a, lower b
    bitbrick uut2 (.a(b[3:2]), .b(a[1:0]), .sel(_signed_unsigned), .p(p2));  // Lower a, upper b
    bitbrick uut3 (.a(a[3:2]), .b(b[3:2]), .sel(_signed), .p(p3));  // Upper 2x2 bits - d

    assign product = (p3 <<< 4) + (p1 <<< 2) + (p2 <<< 2) + p0;

    // From the paper "A Precision-Scalable Energy-Efficient Convolutional Neural Network Accelerator"
    initial begin
        a = 4'b1011; b = 4'b0110; #10;
        $display("Multiplication of 4-bit numbers using bitbrick");
        $display("a = %b, b = %b\n", a, b);
        $display("Partial Product p0 (lower 2x2): %b", p0);
        $display("Partial Product p1 (upper a, lower b): %b", p1);
        $display("Partial Product p2 (lower a, upper b): %b", p2);
        $display("Partial Product p3 (upper 2x2): %b", p3);
        $display("Final product = %b\n", product);

        $finish;
    end

endmodule
