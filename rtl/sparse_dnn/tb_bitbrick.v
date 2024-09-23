module tb_bitbrick();

    reg [1:0] a, w;
    reg sel;
    wire [3:0] p;
    
    bitbrick uut (
        .a(a),
        .w(w),
        .sel(sel),
        .p(p)
    );

    initial begin
        // Test Case 1: Unsigned multiplication
        a = 2'b01; w = 2'b10; sel = 1; #10;
        $display("Test Case 1 - Unsigned: a = %b, w = %b, sel = %b, p = %b", a, w, sel, p);

        // Test Case 2: Signed multiplication
        a = 2'b01; w = 2'b11; sel = 0; #10;
        $display("Test Case 2 - Signed and unsigned: a = %b, w = %b, sel = %b, p = %b", a, w, sel, p);

        // Test Case 3: Signed and unsigned multiplication
        a = 2'b01; w = 2'b01; sel = 0; #10;
        $display("Test Case 3 - Signed: a = %b, w = %b, sel = %b, p = %b", a, w, sel, p);

        // End simulation
        $finish;
    end

endmodule
