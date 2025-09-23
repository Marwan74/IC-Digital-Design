module Spi_Wrapper(clk,rst_n,MISO,MOSI,SS_n);
 input clk,rst_n,SS_n,MOSI;
 output MISO;
 wire [9:0] rx_data_din;
 wire rx_valid_bus,tx_valid_bus;
 wire [7:0] tx_data_dout;

 spi_slave spi (clk,rst_n,SS_n,MOSI,tx_valid_bus,tx_data_dout,MISO,rx_valid_bus,rx_data_din);
 Ram ram (clk,rst_n,rx_data_din,rx_valid_bus,tx_data_dout,tx_valid_bus);

endmodule