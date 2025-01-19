# `snek`

This project is nothing more than just a simple snake game, written in x86_64, for linux, using only kernel interface (syscalls), no libc.

### Why?

I just wanted to practice assembly, I had a lot of theoretical understanding of it, but never tried to solidify it, this project is attempt at it.

And turns out I was unaware of a lot of quirks and details when working in assembly (example: operations where 32-bit register is the destination, zeroes out the other half of the register).

So overall this project definitely helped me understand how correct my knowledge of assembly is, although I must add that I have not used a huge portion of assembly features in this project (atomic operations, simd, instruction encoding, relocations, "modes"), so most of it is still a dark forest to me, but I feel like I've got the fundamentals down.

Another interesting conclusion from this project was that I never want to write assembly directly ever again :)

Which might sound weak, but I've honestly considered improving the current assemblers, and other ways of making it more accessible to write, but every time I think of an idea on how to improve it, my mind instantly jumps to C or any other higher level language that already has these features. Stacking more preprocessor features on a shaky, fractured language won't do it.

Hyperoptimizing specific pieces of code in certain situations is a totally fine usecase, though I would still prefer inline assembly yet again, than direct assembly.

### Known bugs

1) `Ctrl+C` does not work to exit the game while it is paused - this is because game is waiting for a character, not a signal, this could be fixed in a variety of ways, but I don't know if I want to fix this right now.
2) Resizing the terminal during the game leads to all kinds of problems - yes, the game assumes the terminal size stays constant, for simplicity of implementation, all the logic probably could be safeguarded against resizing, but this is a "won't fix" for now.
3) All UI text is skewed to the left a little - macro that calculates the offsets includes the length of non-printable characters for styling, and there isn't really a way to fix it, other than not using the macro which would require some refactoring.
4) Lack of support for "dumb" terminals - Would be a nightmare in assembly, see ncurses database.
5) Overall lack of error handling - the program assumes happy path :) (it's quite difficult to handle errors in assembly, and operations dealing with text especially since you cannot display them to the user in case of an error).
