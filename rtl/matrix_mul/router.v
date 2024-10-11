module router #(
    parameter MaxWidth = 9,  // Maximum number of bytes we can route
    parameter Depth = 32, 
    parameter DataWidth = 8,
    parameter AddrWidth = $clog2(Depth),
    parameter TempAddrWidth = $clog2(MaxWidth)
)(
    input clk, rst, routeEn, // Assume routeEn will be turned on when we want to route
    input [AddrWidth-1:0] startAddr, // Start address of data in buffer
    input [DataWidth-1:0] dataIn,    // Data coming from buffer, assume it is DataWidth
    output reg readEn, finished,
    output reg [AddrWidth-1:0] readAddr, // Address of data in buffer
    output reg [MaxWidth*DataWidth-1:0] dataOut // Data going to PE
);
    // State encoding
    localparam IDLE = 3'b000;
    localparam INITIALIZE = 3'b001;
    localparam ROUTE = 3'b010;
    localparam WAIT = 3'b011; // Wait for data to be sent from buffer to router
    localparam DONE = 3'b100;

    reg [3:0] state;
    reg [TempAddrWidth-1:0] indexCounter;
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
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    readEn <= 0;
                    if (routeEn) begin
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
                    state <= WAIT;  // After initializing, go to STORE
                end
                // We need to wait for data to be sent from buffer to router
                // because it takes one clock cycle for the data to be sent
                WAIT: begin
                    state <= ROUTE;
                end
                ROUTE: begin
                    $display("Data in: %h | readAddr: %h | indexCounter: %h", dataIn, readAddr, indexCounter);
                    TempDataOut[indexCounter] <= dataIn;
                    if (indexCounter < MaxWidth) begin
                        indexCounter <= indexCounter + 1;
                        readAddr <= readAddr + 1;
                        state <= WAIT;
                    end else begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    for (i = 0; i < MaxWidth; i = i + 1) begin
                        // Concatenate TempDataOut into dataOut
                        dataOut[(i+1)*DataWidth-1 -: DataWidth] <= TempDataOut[i];
                    end
                    readEn <= 0;
                    indexCounter <= 0;
                    finished <= 1;
                    state <= IDLE;  // Go back to IDLE after DONE
                end
            endcase
        end
    end

endmodule
