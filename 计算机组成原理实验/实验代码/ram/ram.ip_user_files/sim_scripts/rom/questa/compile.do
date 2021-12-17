vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/dist_mem_gen_v8_0_12
vlib questa_lib/msim/xil_defaultlib

vmap dist_mem_gen_v8_0_12 questa_lib/msim/dist_mem_gen_v8_0_12
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work dist_mem_gen_v8_0_12 -64 \
"../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \

vlog -work xil_defaultlib -64 \
"../../../../ram.srcs/sources_1/ip/rom/sim/rom.v" \


vlog -work xil_defaultlib \
"glbl.v"

