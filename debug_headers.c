/*
 * Debug header for declaring structures to be dumped as debug info,
 * and included in the binary for debugging.
 *
 * Use: should be as simple as `p (snake_t)snake` in gdb.
*/

typedef enum direction {
	Up,
	Right,
	Down,
	Left
} direction_t;

typedef struct snake {
	unsigned short x;
	unsigned short y;
	direction_t direction;
} snake_t;

typedef struct pos {
	unsigned short x;
	unsigned short y;
} pos_t;
