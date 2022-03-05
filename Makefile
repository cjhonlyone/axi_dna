# SHELL := /bin/bash

DEVICE=xc7k325tffg900-2
Vivado_DIR=/cygdrive/c/Xilinx/Vivado/2017.4/bin

# ip:
ip:
	${Vivado_DIR}/vivado -mode tcl -source axi_dna_ip.tcl

clean:
	rm -rf .Xil
	rm -rf axi_spi
	rm -r *.log *.jou *.dmp