%include "syscall.mac"
%include "common.mac"

section .rodata
;; man nanosleep(2)
;; man timespec(3)
;; man time_t(3type)

;; = sleep for 100ms
duration: dq 0, 100_000_000
;;duration: dq 0, 999_999_999

section .text

global nanosleep
nanosleep:
	prologue

	checked_system_call SYSCALL_NANOSLEEP, rdi, 0

	epilogue

global gamesleep
gamesleep:
	prologue

	mov rdi, duration
	call nanosleep

	epilogue
