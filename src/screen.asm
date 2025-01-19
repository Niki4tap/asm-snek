%include "common.mac"
%include "str.inc"
%include "term.inc"
%include "term.mac"
%include "io.mac"
%include "game.inc"

section .text

global setup_screen
setup_screen:
	prologue

	checked enter_cbreak
	checked const_write STDOUT, ENTER_ALTERNATE_SCREEN, HIDE_CURSOR
	call refresh_screen

	epilogue

global refresh_screen
refresh_screen:
	prologue
	checked const_write STDOUT, CLEAR_SCREEN
	epilogue

global write_start_screen
write_start_screen:
	prologue

	call get_win_size
	mov r13w, ax
	mov r14w, dx
	mov rbx, 2
	mov ax, r13w
	div bl
	movzx r13w, al
	mov ax, r14w
	div bl
	movzx r14w, al
	dec r13w
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_ITALIC, "snek - a small snake game written in assembly", STYLE_RESET
	restore r14w
	add r13w, 2
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_BOLD, "press any key to start!", STYLE_RESET
	restore r14w

	add r13w, 2
	checked const_write_at r14w, r13w, STDOUT, "Controls: 'p' or space - pause, wasd or arrow keys - move, 'q' or Ctrl+C - exit"


	epilogue

global write_pause_screen
write_pause_screen:
	prologue

	call get_win_size
	mov r13w, ax
	mov r14w, dx
	mov rbx, 2
	mov ax, r13w
	div bl
	movzx r13w, al
	mov ax, r14w
	div bl
	movzx r14w, al
	dec r13w
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_INVERT, STYLE_ITALIC, "paused!", STYLE_RESET, " score: "
	clean(rdx)
	mov dil, byte [snake_len]
	call int_to_str
	checked write_int
	restore r14w
	add r13w, 2
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_BOLD, "press 'p' or space to continue.", STYLE_RESET
	restore r14w
	add r13w, 2
	checked const_write_at r14w, r13w, STDOUT, "Controls: 'p' or space - pause, wasd or arrow keys - move, 'q' or Ctrl+C - exit"

	epilogue

global write_lost_screen
write_lost_screen:
	prologue

	call get_win_size
	mov r13w, ax
	mov r14w, dx
	mov rbx, 2
	mov ax, r13w
	div bl
	movzx r13w, al
	mov ax, r14w
	div bl
	movzx r14w, al
	dec r13w
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_INVERT, STYLE_ITALIC, "you lost!", STYLE_RESET, " final score: "
	clean(rdx)
	mov dil, byte [snake_len]
	call int_to_str
	checked write_int
	restore r14w
	add r13w, 2
	checked const_write_at r14w, r13w, STDOUT, STYLE_BOLD, "press 'r' to restart", STYLE_RESET, ", or 'q' to exit"

	epilogue

global write_won_screen
write_won_screen:
	prologue

	call get_win_size
	mov r13w, ax
	mov r14w, dx
	mov rbx, 2
	mov ax, r13w
	div bl
	movzx r13w, al
	mov ax, r14w
	div bl
	movzx r14w, al
	dec r13w
	preserve r14w
	checked const_write_at r14w, r13w, STDOUT, STYLE_INVERT, STYLE_ITALIC, "you won!", STYLE_RESET, " final score: "
	clean(rdx)
	mov dil, byte [snake_len]
	call int_to_str
	checked write_int
	restore r14w
	add r13w, 2
	checked const_write_at r14w, r13w, STDOUT, STYLE_BOLD, "press 'r' to restart", STYLE_RESET, ", or 'q' to exit"

	epilogue

global teardown_screen
teardown_screen:
	prologue

	checked const_write STDOUT, EXIT_ALTERNATE_SCREEN, SHOW_CURSOR
	checked exit_cbreak

	epilogue
