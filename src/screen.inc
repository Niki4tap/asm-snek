%ifndef SCREEN_INC
%define SCREEN_INC

section .text
extern setup_screen
extern refresh_screen
extern teardown_screen
extern write_start_screen
extern write_pause_screen
extern write_lost_screen
extern write_won_screen

%endif
