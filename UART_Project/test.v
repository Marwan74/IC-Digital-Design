module UART_tb ();
    parameter WIDTH = 8;

    reg clk, rst;
    
    // -------------------------------
    // UART_A
    // -------------------------------
    reg rx_rd_en_A, tx_wr_en_A;
    reg [WIDTH - 1 : 0] din_A;
    wire rx_empty_A, rx_full_A, tx_full_A, rx_frame_error_A;
    wire [WIDTH - 1 : 0] dout_A;

    // -------------------------------
    // UART_B
    // -------------------------------
    reg rx_rd_en_B, tx_wr_en_B;
    reg [WIDTH - 1 : 0] din_B;
    wire rx_empty_B, rx_full_B, tx_full_B, rx_frame_error_B;
    wire [WIDTH - 1 : 0] dout_B;

    // -------------------------------
    // Connections between tow UARTs
    // -------------------------------
    wire tx_to_rx_A, tx_to_rx_B;
    
    // -------------------------------
    // Module Instantiations
    // -------------------------------
    UART_wrapper uart_A (.clk(clk), .rst(rst), .rx(tx_to_rx_B), .rx_rd_en(rx_rd_en_A), .tx_wr_en(tx_wr_en_A),
                         .din(din_A), .rx_empty(rx_empty_A), .rx_full(rx_full_A), .tx(tx_to_rx_A),
                         .tx_full(tx_full_A), .framing_error(rx_frame_error_A),
                         .dout(dout_A));

    UART_wrapper uart_B (.clk(clk), .rst(rst), .rx(tx_to_rx_A), .rx_rd_en(rx_rd_en_B), .tx_wr_en(tx_wr_en_B),
                         .din(din_B), .rx_empty(rx_empty_B), .rx_full(rx_full_B), .tx(tx_to_rx_B),
                         .tx_full(tx_full_B), .framing_error(rx_frame_error_B),
                         .dout(dout_B));

    initial begin
        clk = 0;
        forever
            #1 clk = ~ clk;
    end

    initial begin
        rst = 1'b1;
        rx_rd_en_A = 1'b0;
        tx_wr_en_A = 1'b1;
        din_A = $random;
        @ (negedge clk);
        rst = 1'b0;

        repeat (16) begin
            din_A = $random;
            @(negedge clk);
        end
        tx_wr_en_A = 1'b0;
        repeat (1000000) @(negedge clk);
       
        repeat (18) begin
            rx_rd_en_A = 1'b1;
            @(negedge clk);
            rx_rd_en_A = 1'b0;
            repeat (10000) @(negedge clk);
        end
        $stop;
    end

    initial begin
        rst = 1'b1;
        rx_rd_en_B = 1'b0;
        tx_wr_en_B = 1'b1;
        din_B = $random;
        @ (negedge clk);
        rst = 1'b0;

        repeat (16) begin
            din_B = $random;
            @(negedge clk);
        end
        tx_wr_en_B = 1'b0;
        repeat (1000000) @(negedge clk);
       
        repeat (18) begin
            rx_rd_en_B = 1'b1;
            @(negedge clk);
            rx_rd_en_B = 1'b0;
            repeat (10000) @(negedge clk);
        end
        $stop;
    end
endmodule