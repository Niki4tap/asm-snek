%include "syscall.mac"
%include "io.mac"
%include "args.inc"
%include "args.mac"
%include "bool.mac"
%include "common.mac"

%define VERSION "1.0.0"
%xdefine VERSION_STR %strcat("snek v", VERSION, ", assembled on ", __?UTC_DATE?__, " by nasm v", __?NASM_VER?__)

section .rodata
help_flag: db `-h\0`
version_flag: db `-v\0`

section .text
extern strlen
extern strcmp

global parse_args
parse_args:
	prologue
	mov rax, [argc]
	cmp rax, 1
	je no_args
	cmp rax, 3
	je too_many_args
	get_argv rdi, 1
	mov rsi, help_flag
	call strcmp
	jmp_if_eq rax, true, help
	mov rsi, version_flag
	call strcmp
	jmp_if_eq rax, true, print_ver
	jmp unknown_arg
help:
	call print_help
	mov rax, false
	epilogue
unknown_arg:
	checked const_write STDOUT, "unknown arguments.", `\n`
	call print_help
	mov rax, false
	epilogue
print_ver:
	checked const_write STDOUT, VERSION_STR, `\n`
	mov rax, false
	epilogue
no_args:
	mov rax, true
	epilogue
too_many_args:
	checked	const_write STDOUT, "too many arguments.", `\n`
	call print_help
	mov rax, false
	epilogue

print_help:
	prologue
	get_argv rdi, 0
	call strlen
	mov rbx, rax
	get_argv rcx, 0
	;; NOTE: this is a bit tricky, but fine I think?
	;; (rcx will get clobbered, but before use)
	;; just make sure to never use rcx after this
	checked write_str STDOUT, rcx, rbx
	checked const_write STDOUT, \
		" - a little snake game written in assembly",	`\n`, \
		`\t`, "-h ", "Display this message",				`\n`, \
		`\t`, "-v ", "Output version",						`\n`
	epilogue
