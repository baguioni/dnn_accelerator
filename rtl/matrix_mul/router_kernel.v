module router_kernel #(
    parameter MaxWidth = 9,  // Maximum number of bytes we can route
    parameter KernelSize = 3,
    parameter Depth = 32, 
    parameter DataWidth = 8,
    parameter AddrWidth = $clog2(Depth),
    parameter TempAddrWidth = $clog2(MaxWidth)
)(
    input clk, rst, routeEn, // Assume routeEn will be turned on when we want to route
    input [AddrWidth-1:0] startAddr, // Start address of data in buffer
    input [DataWidth-1:0] dataIn,    // Data coming from buffer, assume it is DataWidth
    input [AddrWidth-1:0] inputWidth, // Size of input. Assume square input
    output reg readEn, finished,
    output reg [3:0] state,
    output reg [AddrWidth-1:0] readAddr, // Address of data in buffer
    output reg [AddrWidth-1:0] lastReadAddr, // Last Read Address of data. Used for routing next set of data
    output reg [MaxWidth*DataWidth-1:0] dataOut // Data going to PE
);
    // State encoding
    localparam IDLE = 3'b000;
    localparam INITIALIZE = 3'b001;
    localparam ROUTE = 3'b010;
    localparam WAIT = 3'b011; // Wait for data to be sent from buffer to router
    localparam OUTPUT = 3'b100;
    localparam CHECK = 3'b101;

    reg [TempAddrWidth-1:0] indexCounter;
    reg [DataWidth-1:0] TempDataOut [0:MaxWidth-1];

    reg [2:0] colCounter, outputColCounter;
    reg [AddrWidth-1:0] outputWidth, outputCount;
    reg [AddrWidth-1:0] kernelCounter, kernelIncrement;

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
            lastReadAddr <= 0;
            readEn <= 0;
            colCounter <= 0;
            outputColCounter <= 0;
            outputWidth <= 0;
            outputCount <= 0;
            kernelCounter <= 1;
            kernelIncrement <= 1;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    readEn <= 0;
                    if (routeEn) begin// Logic to calculate next readAddr
                        state <= INITIALIZE;  // Move to INITIALIZE when routeEn is asserted
                    end else begin
                        state <= IDLE;  // Stay in IDLE if routeEn is not asserted
                    end
                end
                INITIALIZE: begin
                    indexCounter <= 0;
                    finished <= 0;
                    dataOut <= 0;
                    readAddr <= startAddr;
                    readEn <= 1;
                    colCounter <= 0;
                    outputColCounter <= 0;
                    outputWidth <= inputWidth - KernelSize + 1;
                    outputCount <= (inputWidth - KernelSize + 1) * (inputWidth - KernelSize + 1); // Figure out better way to calculate this
                    kernelCounter <= 1;
                    kernelIncrement <= 1;
                    state <= WAIT;  // After initializing, go to STORE
                end
                // We need to wait for data to be sent from buffer to router
                // because it takes one clock cycle for the data to be sent
                WAIT: begin
                    state <= ROUTE;
                end
                ROUTE: begin
                    // $display("Data in: %h | readAddr: %h | indexCounter: %h", dataIn, readAddr, indexCounter);
                    // Need outputColCounter and colcounter
                    TempDataOut[indexCounter] <= dataIn;
                    if (indexCounter < MaxWidth) begin
                        indexCounter <= indexCounter + 1;
                        //$display("readAddr: %h | indexCounter: %h", readAddr, indexCounter);
                        // Logic to calculate next readAddr
                        if (colCounter < KernelSize - 1) begin
                            readAddr <= readAddr + 1;
                            colCounter <= colCounter + 1;
                        end else begin
                            // Input Size - Kernel Size + 1 
                            readAddr <= readAddr + (inputWidth - KernelSize + 1);
                            colCounter <= 0;
                        end

                        state <= WAIT;
                    end else begin
                        state <= OUTPUT;
                    end
                end
                OUTPUT: begin
                    for (i = 0; i < MaxWidth; i = i + 1) begin
                        // Concatenate TempDataOut into dataOut
                        dataOut[(i+1)*DataWidth-1 -: DataWidth] <= TempDataOut[i];
                    end
                    readEn <= 0;
                    indexCounter <= 0;
                    lastReadAddr <= readAddr;
                    state <= CHECK;  // Go back to IDLE after DONE
                end
                CHECK: begin
                    // Check if we need to route more data
                    $display("%h", dataOut);
                    if (kernelCounter < outputCount) begin
                        // input width - kernel size + 1 
                        if (outputColCounter < outputWidth - 1) begin
                            readAddr <= startAddr + kernelIncrement;
                            outputColCounter <= outputColCounter + 1;
                            kernelIncrement <= kernelIncrement + 1;
                        end else begin
                            readAddr <= startAddr + kernelIncrement + KernelSize - 1;
                            kernelIncrement <= kernelIncrement + KernelSize;
                            outputColCounter <= 0;
                        end
                        kernelCounter <= kernelCounter + 1;

                        state <= WAIT;
                        readEn <= 1;
                    end else begin
                        finished <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
