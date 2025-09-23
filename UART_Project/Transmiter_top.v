module Transmitter_TOP (clk, rst, S_tick, tx_wr_data, tx_wr_en, tx, tx_full);
    parameter N_BIT = 8;  // Data width (8 bits)
    
    // -------------------------------
    // Inputs
    // -------------------------------
    input clk, rst, S_tick, tx_wr_en;
    input [N_BIT - 1 : 0] tx_wr_data;

    // -------------------------------
    // Outputs
    // -------------------------------
    output tx, tx_full;
    
    // -------------------------------
    // Internal Wires (connections between modules)
    // -------------------------------
    wire tx_done_tick;  // Read enable for TX FIFO (from TX done)
    wire [N_BIT - 1 : 0] tx_rd_data;  // Data from TX FIFO to TX
    wire tx_empty;  // TX FIFO empty flag (used to start TX)
    
    // -------------------------------
    // Module Instantiations
    // -------------------------------
    // UART Transmitter
    transmiter transmitter (.clk(clk), .s_tick(S_tick), .rst(rst), .tx_start(~ tx_empty), 
                         .tx_data(tx_rd_data), .tx_out(tx), .tx_done_stick(tx_done_tick));
    // TX FIFO (holds data before transmission)
    fifo tx_fifo (.clk(clk), .rst(rst), .wr_en(tx_wr_en), .w_data(tx_wr_data), 
                       .rd_en(tx_done_tick), .r_data(tx_rd_data), .empty(tx_empty), .full(tx_full));
endmodule