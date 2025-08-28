vlib work
vlog DSP.v DSP_tb.v MUX.v
vsim -voptargs=+acc work.DSP_tb
add wave *
run -all
#quit -sim