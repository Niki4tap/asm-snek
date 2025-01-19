%include "common.mac"
%include "game.mac"
%include "mem.inc"
%include "str.inc"
%include "io.mac"
%include "term.inc"
%include "term.mac"
%include "rand.inc"
%include "rand.mac"
%include "bool.mac"
%include "sleep.inc"
%include "input.inc"
%include "screen.inc"
%include "syscall.mac"

section .data
global snake_len
snake_len: db 0
snake_char: db 'X'
snake: times MAX_SNAKE_LEN * snake_tile_size db 0
swap_snake: snake_tile_zero
apple: pos_zero
global game_state
game_state: db GAME_STATE_RUNNING
r: dw 0x0000

section .text

global game_reset_state
game_reset_state:
	prologue

	mov byte [game_state], true
	mov byte [snake_len], 0

	mov rdi, snake
	mov rsi, 0
	mov rdx, %eval(snake_tile_size * 100)
	call memset

	mov rdi, apple
	mov rsi, 0
	mov rdx, pos_size
	call memset

	call get_win_size
	mov r10w, ax
	mov r11w, dx

	mov r12w, 2

	mov ax, r10w
	clean(dx)
	div r12w
	mov word [snake+snake_tile.y], ax
	mov ax, r11w
	clean(dx)
	div r12w
	mov word [snake+snake_tile.x], ax

	mov byte [snake+snake_tile.direction], DIRECTION_UP
	mov byte [snake_char], '^'

	call new_apple

	epilogue

global game_tick_state
game_tick_state:
	prologue

	call refresh_screen
	call game_render
	call gamesleep
	call last_char
	mov rdi, rdx
	call game_process_input
	cmp byte [game_state], GAME_STATE_PAUSED
	je .end
	call game_process_move
	jmp .end

.end:
	epilogue

global game_render_snake
game_render_snake:
	prologue
	preserve 'all'

	mov r14b, 1
	mov r15b, byte [snake_len]
.loop:
	cmp r14b, r15b
	jg .end

	mov rax, snake_tile_size
	mul r14b
	add rax, snake

	mov r12w, word [rax+snake_tile.x]
	mov r13w, word [rax+snake_tile.y]
	checked const_write_at r12w, r13w, STDOUT, "S"

	inc r14b
	jmp .loop

.end:
	restore 'all'
	epilogue

global game_render
game_render:
	prologue
	preserve r12
	preserve r13

	mov r12w, word [snake+snake_tile.y]
	mov r13w, word [snake+snake_tile.x]
	checked cursor_set_pos(r13w, r12w)
	checked write_str STDOUT, snake_char, 1

	mov r12w, word [apple+pos.y]
	mov r13w, word [apple+pos.x]
	checked const_write_at r13w, r12w, STDOUT, "O"

	call game_render_snake

	restore r13
	restore r12
	epilogue

global game_process_input
game_process_input:
	prologue

	jmp_if_eq rdi, KEY_UP, .up
	jmp_if_eq rdi, 'w', .up

	jmp_if_eq rdi, KEY_RIGHT, .right
	jmp_if_eq rdi, 'd', .right

	jmp_if_eq rdi, KEY_DOWN, .down
	jmp_if_eq rdi, 's', .down

	jmp_if_eq rdi, KEY_LEFT, .left
	jmp_if_eq rdi, 'a', .left

	jmp_if_eq rdi, 'q', .exit_game

	jmp_if_eq rdi, 'p', .pause_game
	jmp_if_eq rdi, ' ', .pause_game

	jmp .end
.up:
	jmp_if_eq byte [snake+snake_tile.direction], DIRECTION_DOWN, .end
	mov byte [snake+snake_tile.direction], DIRECTION_UP
	mov byte [snake_char], '^'
	jmp .end
.right:
	jmp_if_eq byte [snake+snake_tile.direction], DIRECTION_LEFT, .end
	mov byte [snake+snake_tile.direction], DIRECTION_RIGHT
	mov byte [snake_char], '>'
	jmp .end
.down:
	jmp_if_eq byte [snake+snake_tile.direction], DIRECTION_UP, .end
	mov byte [snake+snake_tile.direction], DIRECTION_DOWN
	mov byte [snake_char], 'v'
	jmp .end
.left:
	jmp_if_eq byte [snake+snake_tile.direction], DIRECTION_RIGHT, .end
	mov byte [snake+snake_tile.direction], DIRECTION_LEFT
	mov byte [snake_char], '<'
	jmp .end
.exit_game:
	mov byte [game_state], GAME_STATE_STOP
	jmp .end
.pause_game:
	mov byte [game_state], GAME_STATE_PAUSED
	jmp .end
.end:
	epilogue

global snake_next_pos
snake_next_pos:
	prologue

	jmp_if_eq byte [rdi+snake_tile.direction], DIRECTION_UP, .up
	jmp_if_eq byte [rdi+snake_tile.direction], DIRECTION_RIGHT, .right
	jmp_if_eq byte [rdi+snake_tile.direction], DIRECTION_DOWN, .down
	jmp_if_eq byte [rdi+snake_tile.direction], DIRECTION_LEFT, .left

	jmp .end
.up:
	mov ax, word [rdi+snake_tile.x]
	mov dx, word [rdi+snake_tile.y]
	dec dx
	jmp .end
.right:
	mov ax, word [rdi+snake_tile.x]
	mov dx, word [rdi+snake_tile.y]
	inc ax
	jmp .end
.down:
	mov ax, word [rdi+snake_tile.x]
	mov dx, word [rdi+snake_tile.y]
	inc dx
	jmp .end
.left:
	mov ax, word [rdi+snake_tile.x]
	mov dx, word [rdi+snake_tile.y]
	dec ax
	jmp .end
.end:
	epilogue

global new_apple
new_apple:
	prologue
	preserve r12
	preserve r13

	call get_win_size
	mov r13w, ax
	mov r12w, dx

	checked rand_word r
	clean(dx)
	mov ax, [r]
	div r12w
	inc dx
	mov word [apple+pos.x], dx

	checked rand_word r
	clean(dx)
	mov ax, [r]
	div r13w
	inc dx
	mov word [apple+pos.y], dx

	restore r13
	restore r12
	epilogue

global new_snake
new_snake:
	prologue

	mov cl, byte [snake_len]
	mov rax, snake_tile_size
	mul cl
	add rax, snake

	mov rdi, swap_snake
	mov rsi, rax
	mov rdx, snake_tile_size
	call memcpy

	inc byte [snake_len]

	epilogue

global move_snake
move_snake:
	prologue
	preserve r12
	preserve r13
	preserve r14

	clean(r12b)
	mov r13b, byte [snake+snake_tile.direction]
.loop:
	mov rax, snake_tile_size
	mul r12b
	add rax, snake
	mov r14, rax
	mov rdi, rax
	call snake_next_pos

	mov [r14+snake_tile.x], ax
	mov [r14+snake_tile.y], dx
	xchg [r14+snake_tile.direction], r13b

	cmp r12b, byte [snake_len]
	je .end
	inc r12b
	jmp .loop

.end:
	restore r14
	restore r13
	restore r12
	epilogue

global snake_append_tail
snake_append_tail:
	prologue

	mov cl, byte [snake_len]
	mov rax, snake_tile_size
	mul cl
	add rax, snake

	mov rdi, rax
	mov rsi, swap_snake
	mov rdx, snake_tile_size
	call memcpy

	epilogue

global game_check_snake
game_check_snake:
	prologue
	preserve 'all'

	mov r14b, 1
	mov r15b, byte [snake_len]
.loop:
	cmp r14b, r15b
	jg .end

	mov rax, snake_tile_size
	mul r14b
	add rax, snake

	mov r12w, word [rax+snake_tile.x]
	mov r13w, word [rax+snake_tile.y]

	jmp_if_ne si, r12w, .cont_loop
	jmp_if_ne di, r13w, .cont_loop

	mov byte [game_state], GAME_STATE_LOST
	jmp .end

.cont_loop:
	inc r14b
	jmp .loop

.end:
	restore 'all'
	epilogue

global game_process_move
game_process_move:
	prologue
	preserve r12
	preserve r13

	mov rdi, snake
	call snake_next_pos

	mov r12w, dx
	mov r13w, ax
	mov di, dx
	mov si, ax
	call game_check_snake
	jmp_if_eq byte [game_state], GAME_STATE_LOST, .end

	call get_win_size
	xchg r12w, dx
	xchg r13w, ax

	jmp_if_at ax, r12w, .lost
	jmp_if_eq ax, 0, .lost
	jmp_if_at dx, r13w, .lost
	jmp_if_eq dx, 0, .lost

	jmp_if_ne ax, [apple+pos.x], .only_move
	jmp_if_ne dx, [apple+pos.y], .only_move

	jmp_if_ne byte [snake_len], %eval(MAX_SNAKE_LEN - 1), .not_won

	mov byte [game_state], GAME_STATE_WON
	jmp .end

.not_won:
	call new_apple
	call new_snake
	call move_snake
	call snake_append_tail
	jmp .end

.only_move:
	call move_snake
	jmp .end

.lost:
	mov byte [game_state], GAME_STATE_LOST
	jmp .end

.end:
	restore r13
	restore r12
	epilogue
