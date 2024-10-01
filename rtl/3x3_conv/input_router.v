module input_router(
    input clk, rst, state,
    output reg wb_write_en,
    input [71:0] ifmap_in, filter_in, // Assume input data is the sliding window
    output reg [71:0] ifmap_out, filter_out
);

    localparam load = 1; // Load both ifmap and filter
    localparam shift = 0; // Shift ifmap

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_write_en <= 0;
        end else begin
            case (state)
                load: begin
                    ifmap_out <= ifmap_in;
                    filter_out <= filter_in;
                    wb_write_en <= 1;
                end
                shift: begin
                    ifmap_out <= ifmap_in;
                    wb_write_en <= 0;
                end
            endcase
        end
    end
endmodule