module tb_top;

    // Parameters
    parameter Width = 9;
    parameter Height = 4;
    parameter Size = 9;
    parameter DataWidth = 8;
    parameter PsumWidth = 16;

    // Inputs
    reg clk;
    reg rst;
    reg readEn;

    // Outputs
    wire [PsumWidth-1:0] psumOut;

    // Instantiate the top module
    top #(
        .Width(Width),
        .Height(Height),
        .Size(Size),
        .DataWidth(DataWidth),
        .PsumWidth(PsumWidth)
    ) uut (
        .clk(clk),
        .rst(rst),
        .readEn(readEn),
        .psumOut(psumOut)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        readEn = 0;

        // Apply reset
        #20 rst = 0; // Release reset after 20 time units

        // Set readEn high after reset is released
        #10 readEn = 1; // Set readEn high 10 time units after reset is released

        // Let the simulation run for some cycles
        #100;

        // Check psumOut
        $display("Final psumOut: %h", psumOut);

        // Finish the simulation
        $stop;
    end

endmodule
