%include "common.mac"
%include "io.mac"
%include "poll.mac"

section .data
c: dd 0x00000000
poller: pollfd_zero

section .text
global eat_char
eat_char:
	prologue

	mov rdi, -1
	call wait_for_char

	epilogue

global wait_for_char
wait_for_char:
	prologue
	mov dword [c], 0x00000000

	mov r10, rdi
	mk_poll poller, STDIN, POLLIN
	checked poll poller, 1, r10
	cmp rax, 0
	je .no_char

	checked_system_call SYSCALL_READ, STDIN, c, 4
	mov edx, dword [c]
	jmp .end

.no_char:
	clean(rax)
	clean(rdx)
	jmp .end
.end:
	epilogue

global last_char
last_char:
	prologue
	preserve r12
	preserve r13
	clean(r12)
	clean(r13)

.again:

	mov rdi, 0
	call wait_for_char
	jmp_if_eq rax, 0, .end
	mov r12, rax
	mov r13, rdx
	jmp .again

.end:
	mov rax, r12
	mov rdx, r13
	restore r13
	restore r12
	epilogue
