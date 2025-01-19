%include "common.mac"
%include "term.mac"
%include "io.mac"

section .bss
global original_term
original_term: resb termios2_size
global term
term: resb termios2_size

section .text

;; terminal window size: https://www.delorie.com/djgpp/doc/libc/libc_495.html
global get_win_size
get_win_size:
	prologue
	sub rsp, winsize_size
	checked_system_call SYSCALL_IOCTL, STDIN, TIOCGWINSZ, rsp
	mov ax, c_short_ptr [rsp+winsize.ws_row]
	mov dx, c_short_ptr [rsp+winsize.ws_col]

	epilogue
