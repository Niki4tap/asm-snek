%include "common.mac"

section .text

global memcpy
memcpy:
	prologue
.loop:
	dec rdx
	mov r10b, byte [rsi + rdx]
	mov byte [rdi + rdx], r10b
	cmp rdx, 0
	je .end
	jmp .loop
.end:
	epilogue

global memset
memset:
	prologue
.loop:
	dec rdx
	mov byte [rdi + rdx], sil
	cmp rdx, 0
	je .end
	jmp .loop
.end:
	epilogue

