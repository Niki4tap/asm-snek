%ifndef GAME_INC
%define GAME_INC

section .data
extern snake_len
extern snake
extern apple
extern game_state

section .text
extern game_reset_state
extern game_tick_state

%endif
