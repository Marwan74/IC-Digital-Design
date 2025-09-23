vlib work
vlog Spi_slave.v test.v Ram.v Spi_Wrapper.v 
vsim -voptargs=+acc work.spii_test
add wave *
add wave -position insertpoint  \
sim:/spii_test/dut/spi/tx_valid \
sim:/spii_test/dut/spi/tx_data \
sim:/spii_test/dut/spi/rx_valid \
sim:/spii_test/dut/spi/rx_data \
sim:/spii_test/dut/spi/cs \
sim:/spii_test/dut/spi/ns \
sim:/spii_test/dut/spi/counter_1 \
sim:/spii_test/dut/spi/counter_2 \
sim:/spii_test/dut/spi/ckh_read_address
add wave -position insertpoint  \
sim:/spii_test/dut/ram/mem \
sim:/spii_test/dut/ram/addr
run -all
#quit -sim