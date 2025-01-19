%include "common.mac"
%include "syscall.mac"
%include "signal.mac"
%include "game.mac"
%include "game.inc"

section .rodata
interrupt_sigaction:
istruc sigaction
	at .handler, c_long_n(d, interrupt_handler)
	at .flags, c_long_n(d, SA_RESTORER)
	at .restorer, c_long_n(d, restorer)
	at .mask, c_long_n(d, 0)
iend

section .text
global set_interrupt_handler
set_interrupt_handler:
	prologue

	checked_system_call SYSCALL_RT_SIGACTION, SIGINT, interrupt_sigaction, 0, 8

	epilogue

global interrupt_handler
interrupt_handler:
	;; NOTE: no prologue/epilogue, signal code

	mov byte [game_state], GAME_STATE_STOP

	;; NOTE: ret here is fine since we have a restorer
	ret

global restorer
restorer:
	;; NOTE: no prologue/epilogue, signal code
	checked_system_call SYSCALL_RT_SIGRETURN
