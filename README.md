# Sha3-256

SHA3-256 implementation in VHDL for a Digilent Basys3 FPGA.


## Program the board

Add all `.vhd` and `.xdc` files in Vivado to generate a bitstream and flash it onto the device.\
The `rounds` directory contains variants for the Keccak f-funciton, that calculate a varying number of rounds in one clock cycle, i.e. `round_1.vhd` computes 1 round per cycle, `round_2.vhd` does 2 rounds per cycle, etc.\
To make use of these variants, copy the desired file to `round.vhd` in the root directory of the repo.\
Of course, the counter value of the `st_process` state of the FSM needs to be adjusted in `control_path.vhd` as well, i.e. with 1 round per cycle, the counter needs to count to 24, with 2 rounds per cycle, the counter only needs to count to 12, etc.\
The testbench files ending in `*_tb.vhd` may be omitted.\
Alternatively, use `top.bit` directly to program the device.


## Communicate with the board

Run the Python script `_uart.py`.

The uart protocol expects 35 messages to send one data block.\
First, a 32 bit (4 bytes) command message, followed by a 1088 bit (136 bytes) data message.

The first bit of the command message determines whether the FPGA will wait for additional data or return the message digest after computing the Keccak f()-function.

* `0` wait for more data
* `1` return the message digest

The data message is always 1088 bits in length and can contain any value.\
The output is always 256 bits in length.
