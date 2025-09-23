vlib work
vlog Baud_Generator.v Reciever.v Transmiter.v fifo.v Transmiter_top.v Receiver_top.v UART_Wrapper.v test.v
vsim -voptargs=+acc work.UART_tb
#add wave *
add wave -position insertpoint  \
sim:/UART_tb/WIDTH \
sim:/UART_tb/clk \
sim:/UART_tb/rst \
sim:/UART_tb/rx_rd_en_A \
sim:/UART_tb/tx_wr_en_A \
sim:/UART_tb/din_A \
sim:/UART_tb/rx_empty_A \
sim:/UART_tb/rx_full_A \
sim:/UART_tb/tx_full_A \
sim:/UART_tb/rx_frame_error_A \
sim:/UART_tb/dout_A \
sim:/UART_tb/rx_rd_en_B \
sim:/UART_tb/tx_wr_en_B \
sim:/UART_tb/din_B \
sim:/UART_tb/rx_empty_B \
sim:/UART_tb/rx_full_B \
sim:/UART_tb/tx_full_B \
sim:/UART_tb/rx_frame_error_B \
sim:/UART_tb/dout_B \
sim:/UART_tb/tx_to_rx_A \
sim:/UART_tb/tx_to_rx_B
add wave -position insertpoint  \
sim:/UART_tb/uart_B/tx_top/tx_fifo/fifo
add wave -position insertpoint  \
sim:/UART_tb/uart_B/tx_top/transmitter/cs \
sim:/UART_tb/uart_B/tx_top/transmitter/ns \
sim:/UART_tb/uart_B/tx_top/transmitter/tx_shift_reg \
sim:/UART_tb/uart_B/tx_top/transmitter/bit_counter \
sim:/UART_tb/uart_B/tx_top/transmitter/tick_count
add wave -position insertpoint  \
sim:/UART_tb/uart_B/rx_top/rx_fifo/fifo
add wave -position insertpoint  \
sim:/UART_tb/uart_B/rx_top/receiver/dout \
sim:/UART_tb/uart_B/rx_top/receiver/cs \
sim:/UART_tb/uart_B/rx_top/receiver/ns \
sim:/UART_tb/uart_B/rx_top/receiver/sample_counter \
sim:/UART_tb/uart_B/rx_top/receiver/Bit_counter \
sim:/UART_tb/uart_B/rx_top/receiver/rx_shift_reg
add wave -position insertpoint  \
sim:/UART_tb/uart_B/tx_top/tx_done_tick
add wave -position insertpoint  \
sim:/UART_tb/uart_B/rx_top/rx_done_tick
run -all
#quit -sim