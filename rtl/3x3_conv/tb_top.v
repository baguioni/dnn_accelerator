`timescale 1ns / 1ps

module tb_top;
    reg clk, rst, state;
    reg [71:0] ifmap_in, filter_in, ifmap_data;
    wire [15:0] psumOut;

    integer ifmap_file, r, psum_file;
    reg first_line;

    top uut (
        .clk(clk),
        .rst(rst),
        .state(state),
        .ifmap_in(ifmap_in),
        .filter_in(filter_in),
        .psumOut(psumOut)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        state = 1;
        ifmap_in = 0;
        rst = 0;
        filter_in = 72'h010000000100000001;
        first_line = 1;

        ifmap_file = $fopen("test.dat", "r");
        if (ifmap_file == 0) begin
            $display("Error test.dat");
            $finish;
        end

        psum_file = $fopen("psumOut.dat", "w");
        if (psum_file == 0) begin
            $display("Error psumOut.dat");
            $finish;
        end

        #10;


        while (!$feof(ifmap_file)) begin
            r = $fscanf(ifmap_file, "%h\n", ifmap_data);
            #10;
            ifmap_in = ifmap_data;

            if (first_line) begin
                state = 1;
                first_line = 0;
            end else begin
                state = 0;
            end

            #5;
            $fwrite(psum_file, "%d\n", psumOut);
        end

        $fclose(ifmap_file);
        $fclose(psum_file);

        #50;
        $finish;
    end

    initial begin
        $monitor("time %t, psumOut = %h, state = %b, ifmap_in = %h, filter_in = %h",
                 $time, psumOut, state, ifmap_in, filter_in);
    end
endmodule
