// iverilog -o dsn router.v buffer.v memory_top.v tb_memory_top.v
module tb_memory_top;
    localparam MaxWidth = 9;
    localparam Depth = 32;  
    localparam DataWidth = 8;
    localparam AddrWidth = $clog2(Depth);

    reg clk, rst, routeEn, writeEn;
    reg [AddrWidth-1:0] writeAddr, startAddr;
    reg [DataWidth-1:0] dataIn;

    wire finished;
    wire [MaxWidth*DataWidth-1:0] dataOut;

    integer file, status;
    reg [DataWidth*2-1:0] readData;

    memory_top memory_top_inst (
        .clk(clk),
        .rst(rst),
        .routeEn(routeEn),
        .writeEn(writeEn),
        .writeAddr(writeAddr),
        .startAddr(startAddr),
        .dataIn(dataIn),
        .finished(finished),
        .dataOut(dataOut)
    );

    always begin
        #5 clk = ~clk;
    end

    integer i;
    initial begin
        clk = 0;
        rst = 1;
        routeEn = 0;
        writeEn = 0;
        writeAddr = 0;
        startAddr = 0;
        dataIn = 0;

        #10 rst = 0;

        file = $fopen("ifmap.mem", "r");
        if (file == 0) begin
            $display("Error: Could not open file!");
            $stop;
        end

        i = 0;
        while (!$feof(file)) begin
            status = $fscanf(file, "%h\n", readData);

            writeEn = 1;
            writeAddr = i;
            dataIn = readData[DataWidth-1:0];

            #10;
            i = i + 1;
        end

        $fclose(file);

        writeEn = 0;
        startAddr = 0;
        #10 routeEn = 1;

        wait (finished);

        #10 $display("Final routed data: %h", dataOut);

        #10 $finish;
    end

endmodule
