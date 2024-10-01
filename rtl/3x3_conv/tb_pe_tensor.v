module tb_pe_tensor;
    parameter N = 1;
    
    reg clk;
    reg rst;
    reg wb_write_en;
    reg [72 * N - 1:0] ifmap;
    reg [72 * N - 1:0] filter;
    wire [16 * N - 1:0] psumOut;

    pe_tensor uut (
        .clk(clk),
        .rst(rst),
        .wb_write_en(wb_write_en),
        .ifmap(ifmap),
        .filter(filter),
        .psumOut(psumOut)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rst = 1;
        wb_write_en = 0;
        ifmap = 0;
        filter = 0;

        #20 rst = 0;

        #10 wb_write_en = 1;
        filter = 72'h010000000100000001;
        #10 wb_write_en = 0;
        #10;
        ifmap = 72'hFEDCBA987654321;
        #20;
        $display("ifmap = %h, filter = %h, psumOut = %d", ifmap, filter, psumOut);
        #20;
        ifmap = 72'hFADCBA987324321;
        #20;
        $display("ifmap = %h, filter = %h, psumOut = %d", ifmap, filter, psumOut);
        #20;
        $finish;
    end

endmodule
