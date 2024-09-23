module tb_mfu;

    reg [7:0] a;          // 8-bit activation input
    reg [31:0] w;         // 32-bit weights input
    reg [2:0] mode;       // Mode selection input
    wire [63:0] o;        // Output

    // Instantiate the MFU module
    mfu uut (
        .a(a),
        .w(w),
        .mode(mode),
        .o(o)
    );

    initial begin
        mode = 3'b000;

        a = {4{2'b10}};
        w = {16{2'b10}};
        #10;
        $display("Test Case 1 - 2x2 Mode");
        $display("a = %b", a);
        $display("w = %b", w);
        $display("o = %b", o); 

        $finish;
    end

endmodule
