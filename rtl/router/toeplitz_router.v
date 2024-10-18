// For now assume square input and kernel
module router #(
    parameter MaxWidth = 9,  // Maximum number of bytes we can route
    parameter Depth = 32, 
    parameter DataWidth = 8,
    parameter AddrWidth = $clog2(Depth),
    parameter TempAddrWidth = $clog2(MaxWidth)
)(
    input clk, rst, routeEn,
    input [AddrWidth-1:0] startAddr, finalAddr, kernelSize, inputSize, 
    input [DataWidth-1:0] dataIn,
    output reg readEn, routingOutput, finished,
    output reg [AddrWidth-1:0] readAddr,
    output reg [MaxWidth*DataWidth-1:0] dataOut
);
    // State encoding
    localparam IDLE = 2'b00;
    localparam INITIALIZE = 2'b01;
    localparam PROCESS = 2'b10;
    localparam ROUTE = 2'b11;

    // Base internal signals
    reg validAddr, doneRouting;
    reg [2:0] state;
    reg [TempAddrWidth-1:0] indexCounter;
    reg [DataWidth-1:0] dataInTemp;
    reg [DataWidth-1:0] TempDataOut [0:MaxWidth-1];


    // Strategy specific signals
    reg [AddrWidth-1:0] oWC, oLC , kIC, kOC, outputSize, startAddrReg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end 
    end

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            indexCounter <= 0;
            finished <= 0;
            dataOut <= 0;
            readAddr <= 0;
            readEn <= 0;
            routingOutput <= 0;
            state <= IDLE;
            doneRouting <= 0;
            dataInTemp <= 0;
        end else begin
            case (state)
                IDLE: begin
                    readEn <= 0;

                    if (routeEn) begin
                        state <= INITIALIZE; 
                    end else begin
                        state <= IDLE;
                    end
                end
                INITIALIZE: begin
                    indexCounter <= 0;
                    finished <= 0;
                    dataOut <= 0;
                    readAddr <= startAddr;
                    startAddrReg <= startAddr;
                    readEn <= 1;
                    validAddr <= 0;
                    routingOutput <= 0;
                    oWC <= 0;
                    oLC <= 0;
                    kIC <= 1;
                    kOC <= 0;
                    doneRouting <= 0;
                    dataInTemp <= 0;
                    outputSize <= inputSize - kernelSize + 1;
                    state <= PROCESS;
                end
                PROCESS: begin
                    // $display("input size: %d", inputSize);
                    // $display("kernel size: %d", kernelSize);
                    // $display("output size: %d", outputSize);
                    if (indexCounter < MaxWidth) begin
                        $display("Previous Data in: %d | Current readAddr: %d | indexCounter: %h", dataIn, readAddr, indexCounter);
                        // Stage 1 (Address Generation)

                        // Last iteration we don't increment readAddr

                        readAddr <= startAddrReg + (oWC + kOC) * inputSize + (oLC + kIC);
                        //$display("oWC: %d, oLC: %d, kOC: %d, kIC: %d", oWC, oLC, kOC, kIC);
                        //$display("readAddr: %d, outputWidthCounter: %d, outputLengthCounter: %d, kOC: %d, kIC: %d",readAddr, oWC, oLC, kOC, kIC);

                        /*
                        for i in range(outputSize):
                            for j in range(outputSize):
                                for x in range(kernelSize):
                                    for y in range(kernelSize):
                                        address = (i + x) * inputSize + (j + y)
                        */

                        if (kIC < kernelSize-1) begin
                            kIC <= kIC + 1;
                        end else begin 
                            kIC <= 0;
                            if (kOC < kernelSize-1) begin
                                kOC <= kOC + 1;
                            end else begin 
                                kOC <= 0;
                                // Go route
                                if (oLC < outputSize-1) begin
                                    oLC <= + 1;
                                end else begin
                                    oLC <= 0;
                                    if (oWC < outputSize-1) begin
                                        oWC <= oWC + 1;
                                    end else begin
                                        // $display("Finished routing");
                                        // $display("indexCounter: %d", indexCounter);
                                        doneRouting <= 1;
                                        // state <= ROUTE;
                                    end
                                end
                            end
                        end

                        // Stage 2 (Memory Read)
                        if (validAddr) begin
                            TempDataOut[indexCounter] <= routingOutput ? dataInTemp : dataIn;
                            indexCounter <= indexCounter + 1;
                        end
                    end else begin
                        $display("------------");
                        dataInTemp <= dataIn;
                        indexCounter <= 0;
                        state <= ROUTE;
                    end
                    validAddr <= 1;
                    routingOutput <= 0;
                end
                ROUTE: begin
                    // Stage 3 (Data Routing)
                    for (i = 0; i < MaxWidth; i = i + 1) begin
                        // Concatenate TempDataOut into dataOut
                        dataOut[(i+1)*DataWidth-1 -: DataWidth] <= TempDataOut[i];
                    end
                    routingOutput <= 1;

                    // Stage 4 (Status Check)
                    if (doneRouting) begin
                        readEn <= 0;
                        finished <= 1;
                        state <= IDLE;
                    end else begin
                        readEn <= 1;
                        state <= PROCESS;
                    end
                end
            endcase
        end
    end

endmodule