%include "common.mac"

section .text

global mabs
mabs:
	prologue
	mov rbx, rdi
	sar rdi, 31
	xor rbx, rdi
	sub rbx, rdi
	mov rax, rbx
	epilogue

