module tb_bitbrick;

    // Testbench signals
    reg [1:0] a, b;
    reg [1:0] sel;
    wire [3:0] p;

    // Instantiate the bitbrick module
    bitbrick uut (
        .a(a),
        .b(b),
        .sel(sel),
        .p(p)
    );

    // Testbench procedure
    initial begin
        a = 2'b11; b = 2'b10; sel = 2'b01; #10;
        $display("Test Case a: a = %b, w = %b, sel = %b, p = %b", a, b, sel, p);

        a = 2'b10; b = 2'b10; sel = 2'b10; #10;
        $display("Test Case b: a = %b, w = %b, sel = %b, p = %b", a, b, sel, p);

        a = 2'b11; b = 2'b01; sel = 2'b10; #10;
        $display("Test Case c: a = %b, w = %b, sel = %b, p = %b", a, b, sel, p);

        a = 2'b10; b = 2'b01; sel = 2'b00; #01;
        $display("Test Case d: a = %b, w = %b, sel = %b, p = %b", a, b, sel, p);

        // End simulation
        $finish;
    end

endmodule
