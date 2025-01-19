%include "syscall.mac"
%include "args.inc"
%include "args.mac"
%include "common.mac"
%include "bool.mac"
%include "str.inc"
%include "math.inc"
%include "term.inc"
%include "term.mac"
%include "io.mac"
%include "input.inc"
%include "input.mac"
%include "screen.inc"
%include "rand.inc"
%include "rand.mac"
%include "sleep.inc"
%include "game.mac"
%include "game.inc"
%include "signal.inc"

default REL

section .text
extern parse_args

global _start
_start:
	start_prelude
	prologue

	call parse_args
	jmp_if_eq rax, false, error

	call set_interrupt_handler

	checked rand_open
	call setup_screen
	call write_start_screen
	call eat_char
	jmp .game_start

.game_start:
	call refresh_screen
	call game_reset_state

.gameloop:
	call game_tick_state
	jmp_if_eq byte [game_state], GAME_STATE_STOP, .exit
	jmp_if_eq byte [game_state], GAME_STATE_LOST, .lost
	jmp_if_eq byte [game_state], GAME_STATE_WON, .won
	jmp_if_eq byte [game_state], GAME_STATE_PAUSED, .paused
	jmp .gameloop

.paused:
	call write_pause_screen
.paused_char:
	call eat_char

	jmp_if_eq edx, 'p', .exit_pause
	jmp_if_eq edx, ' ', .exit_pause

	jmp_if_eq edx, 'q', .exit
	jmp_if_eq byte [game_state], GAME_STATE_STOP, .exit
	jmp .paused
.exit_pause:
	mov byte [game_state], GAME_STATE_RUNNING
	jmp .gameloop

.lost:
	call write_lost_screen
.lost_char:
	call eat_char

	jmp_if_eq edx, 'r', .game_start
	jmp_if_eq edx, 'q', .exit

	jmp .lost_char

.won:
	call write_won_screen
.won_char:
	call eat_char

	jmp_if_eq edx, 'r', .game_start
	jmp_if_eq edx, 'q', .exit

	jmp .won_char

.exit:
	call teardown_screen
	checked rand_close

	checked_system_call SYSCALL_EXIT, 0
error:
	checked_system_call SYSCALL_EXIT, 1
