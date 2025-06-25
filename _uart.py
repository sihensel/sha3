import serial
import time


device = serial.Serial('/dev/ttyUSB1')
device.baudrate = 115200    # set Baud rate to 9600
device.bytesize = 8         # Number of data bits = 8
device.parity   = 'N'       # No parity
device.stopbits = 1         # Number of Stop bits = 1


# send the first command message
cmd0 = bytearray(4)
cmd0[0] = 1

data0 = bytearray(136)
data0[0] = 2
data0[132] = 2
# these 3 bytes get ignored by the FPGA for some reason
data0[133] = 2
data0[134] = 2
data0[135] = 2

# send a second message block
# cmd1 = bytearray(4)
# cmd1[0] = 1
#
# data1 = bytearray(136)
# data1[0] = 3


for i in range(4):
    device.write(int.to_bytes(cmd0[i]))

for i in range(136):
    # time.sleep(1)
    device.write(int.to_bytes(data0[i]))

# for i in range(4):
#     device.write(int.to_bytes(cmd1[i]))
#
# for i in range(136):
#     device.write(int.to_bytes(data1[i]))

out = device.read(32)

# the bytes within each word are in reverse order, rearrange them
md = bytearray(32)
for i in range(8):
    md[4 * i + 0] = out[4 * i + 3]
    md[4 * i + 1] = out[4 * i + 2]
    md[4 * i + 2] = out[4 * i + 1]
    md[4 * i + 3] = out[4 * i + 0]

print(md.hex())


# # send more data after reading the first output
# cmd2 = bytearray(4)
# cmd2[0] = 1
#
# data2 = bytearray(136)
# data2[0] = 4
#
# for i in range(4):
#     device.write(int.to_bytes(cmd2[i]))
#
# for i in range(136):
#     device.write(int.to_bytes(data2[i]))
#
# out = device.read(32)
#
# # the bytes within each word are in reverse order, rearrange them
# md = bytearray(32)
# for i in range(8):
#     md[4 * i + 0] = out[4 * i + 3]
#     md[4 * i + 1] = out[4 * i + 2]
#     md[4 * i + 2] = out[4 * i + 1]
#     md[4 * i + 3] = out[4 * i + 0]
#
# print(md.hex())


device.close()
