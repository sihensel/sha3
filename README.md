# Sha3-256

SHA3-256 implementation in VHDL for a Digilent Basys3 FPGA.


## Program the board

Add all `.vhd` and `.xdc` files in Vivado to generate a bitstream and flash it onto the device.\
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
