module tb_memory_kernel_top;
    localparam MaxWidth = 9;
    localparam Depth = 32;  
    localparam DataWidth = 8;
    localparam AddrWidth = $clog2(Depth);

    reg clk, rst, routeEn, writeEn;
    wire [3:0] state;
    reg [AddrWidth-1:0] writeAddr, startAddr;
    reg [AddrWidth-1:0] inputWidth;
    reg [DataWidth-1:0] dataIn;

    wire finished;
    wire [MaxWidth*DataWidth-1:0] dataOut;

    integer file, status;
    reg [DataWidth*2-1:0] readData;

    // State encoding
    localparam IDLE = 3'b000;
    localparam INITIALIZE = 3'b001;
    localparam ROUTE = 3'b010;
    localparam WAIT = 3'b011; 
    localparam OUTPUT = 3'b100;
    localparam CHECK = 3'b101;

    memory_kernel_top memory_kernel_top_inst (
        .clk(clk),
        .rst(rst),
        .routeEn(routeEn),
        .writeEn(writeEn),
        .writeAddr(writeAddr),
        .startAddr(startAddr),
        .inputWidth(inputWidth),
        .dataIn(dataIn),
        .finished(finished),
        .state(state),
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
        inputWidth = 5;
        dataIn = 0;

        #10 rst = 0;

        file = $fopen("ifmap.mem", "r");
        if (file == 0) begin
            $display("Error: Could not open file!");
            $stop;
        end

        // Reading file and writing data to buffer
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
