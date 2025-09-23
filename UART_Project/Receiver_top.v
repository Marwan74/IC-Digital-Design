module Receiver_TOP (clk, rst, S_tick, rx, rx_rd_en, rx_rd_data, rx_empty, rx_full, frame_error);
    parameter N_BIT = 8;  // Data width (8 bits)
    
    // -------------------------------
    // Inputs
    // -------------------------------
    input clk, rst, S_tick, rx, rx_rd_en;

    // -------------------------------
    // Outputs
    // -------------------------------
    output [N_BIT - 1 : 0] rx_rd_data;
    output rx_empty, rx_full, frame_error;

    // -------------------------------
    // Internal Wires (connections between modules)
    // -------------------------------
    wire rx_done_tick;  // Write enable for RX FIFO (from RX done)
    wire [N_BIT - 1 : 0] rx_wr_data;  // Data from RX to RX FIFO

    // -------------------------------
    // Module Instantiations
    // -------------------------------
    // UART Receiver
    Receiver receiver (.clk(clk), .s_tick(S_tick), .rst(rst), .rx_data(rx), .dout(rx_wr_data), 
                      .rx_done_tick(rx_done_tick), .framing_error(frame_error));
    // RX FIFO (stores received data)
    fifo rx_fifo (.clk(clk), .rst(rst), .wr_en(rx_done_tick), .w_data(rx_wr_data), .rd_en(rx_rd_en), 
                       .r_data(rx_rd_data), .empty(rx_empty), .full(rx_full));
endmodule