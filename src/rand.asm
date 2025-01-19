%include "common.mac"

section .rodata
global rand_device
rand_device: db "/dev/urandom", 0

section .data
global rand_fd
rand_fd: c_int(d)
