// Pipelined FSM-based router
module router #(
    parameter MaxWidth = 9,  // Maximum number of bytes we can route
    parameter Depth = 32, 
    parameter DataWidth = 8,
    parameter AddrWidth = $clog2(Depth),
    parameter TempAddrWidth = $clog2(MaxWidth)
)(
    input clk, rst, routeEn, // Assume routeEn will be turned on when we want to route
    input [AddrWidth-1:0] startAddr, finalAddr, // Start address of data in buffer
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
    reg validAddr;
    reg [3:0] state;
    reg [TempAddrWidth-1:0] indexCounter;
    reg [DataWidth-1:0] dataInTemp;
    reg [DataWidth-1:0] TempDataOut [0:MaxWidth-1];

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
            dataInTemp <= 0;
            state <= IDLE;
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
                    readEn <= 1;
                    validAddr <= 0;
                    routingOutput <= 0;
                    dataInTemp <= 0;
                    state <= PROCESS;
                end
                PROCESS: begin
                    //$display("Dataout: %h | readAddr: %h | indexCounter: %h", dataOut, readAddr, indexCounter);
                    if (indexCounter < MaxWidth) begin
                        $display("Previous Data in: %h | Current readAddr: %h | indexCounter: %h", dataIn, readAddr, indexCounter);
                        // Stage 1 (Address Generation)
                        readAddr <= readAddr + 1;
                        
                        // Stage 2 (Memory Read)
                        if (validAddr) begin
                            TempDataOut[indexCounter] <= routingOutput ? dataInTemp : dataIn;
                            indexCounter <= indexCounter + 1;
                        end
                    end else begin
                        // Store dataIn of first  
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
                    if (readAddr >= finalAddr) begin
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