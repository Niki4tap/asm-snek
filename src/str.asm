%include "common.mac"
%include "bool.mac"

section .data
global your_number
your_number: times 20 db 0
global your_number_len
your_number_len: times 16 db 0

section .text

global strlen
strlen:
	prologue
	clean(rax)
.loop:
	mov bl, byte [rdi + rax]
	cmp bl, 0
	je .end
	inc rax
	jmp .loop
.end:
	epilogue

global strcmp
strcmp:
	prologue
	clean(rax)
.loop:
	mov bl, byte [rdi + rax]
	mov cl, byte [rsi + rax]
	cmp bl, cl
	jne .not_eq
	cmp bl, 0
	je .final_check
	inc rax
	jmp .loop
.final_check:
	cmp cl, 0
	je .end
.not_eq:
	mov rax, false
	epilogue
.end:
	mov rax, true
	epilogue

global strncmp
strncmp:
	prologue
	clean(rax)
.loop:
	cmp rdx, 0
	je .eq
	mov bl, byte [rdi + rax]
	mov cl, byte [rsi + rax]
	cmp bl, cl
	jne .not_eq
	dec rdx
	jmp .loop
.not_eq:
	mov rax, false
	epilogue
.eq:
	mov rax, true
	epilogue


global int_to_str
int_to_str:
	prologue
	clean(rdx)
	clean(rcx)
	sub rsp, 20
	mov rax, rdi
	mov r9, 10
.loop:
	clean(rdx)
	div r9
	add dl, 48 ;; ascii '0'
	mov byte [rsp + rcx], dl
	inc rcx
	cmp rax, 0
	je .loop_end
	jmp .loop
.loop_end:
	mov [your_number_len], rcx
	cmp rcx, 0
	je .end
	clean(rdx)
.rev_loop:
	;; rax should be 0 by this point
	dec rcx
	mov al, byte [rsp + rcx]
	mov byte [your_number + rdx], al
	cmp rcx, 0
	je .end
	inc rdx
	jmp .rev_loop
.end:
	epilogue
