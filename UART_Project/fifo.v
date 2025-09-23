module fifo (clk, rst, wr_en, w_data, rd_en, r_data, empty, full);
    parameter WIDTH = 8;
    parameter DEPTH = 16;
    parameter ADDR_SIZE = 4;

    input clk, rst, wr_en, rd_en;
    input [WIDTH - 1 : 0] w_data;
    output empty, full;
    output reg [WIDTH - 1 : 0] r_data;

    reg [WIDTH - 1 : 0] fifo [DEPTH - 1 : 0];
    reg [ADDR_SIZE : 0] wr_ptr, rd_ptr;

    assign full = (wr_ptr[ADDR_SIZE] != rd_ptr[ADDR_SIZE]) && (wr_ptr[ADDR_SIZE - 1 : 0] == rd_ptr[ADDR_SIZE - 1 : 0])? 1 : 0;
    assign empty = (wr_ptr == rd_ptr)? 1 : 0;

    always @ (posedge clk) begin
        if (rst) begin
            r_data <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
        
        else begin
            if (wr_en && (full != 1'b1)) begin
                wr_ptr <= wr_ptr + 1;
                fifo[wr_ptr[ADDR_SIZE - 1 : 0]] <= w_data;
            end
            if (rd_en && (empty != 1'b1)) begin
                rd_ptr <= rd_ptr + 1;
                r_data <= fifo[rd_ptr[ADDR_SIZE - 1 : 0]];
            end
        end

    end
endmodule