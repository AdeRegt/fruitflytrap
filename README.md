# fruitflytrap
## description
Fruitfly engine for KiddieOS and MSDOS 

## build
``` 
fasm fruitfly.asm
```

## execution
```
fruitfly
```

## sample programs
* hello.sxe : displays hello world

## Updates v1.0.0

* Data and code segment separations via the "segment" directive for greater compatibility with KiddieOS. Variables and Buffers are now in the data segment.
* Assignment of the "dates" segment to DS and ES for greater compatibility.
* Organization and Formatting of code syntax, with indentations and tabs, including subdivision of comments.
* Insertion of the Label "command_line" after the presentation strings, for every program or command termination, return the emulator command line.
* Error handling for the "open" function (for opening files), with new Strings.
* Implementation of commands A2RB and A2RA (to save from addresses to registers) containing the inverse logic of RA2A and RB2A. V2RA (Value for Register 'A') and V2RB (Value to Register 'B') was also implemented.
* All errors of "invalid syscall", "invalid flags" and "unknown instruction", presents the error in "errormessage", however, it does not close the emulator as before, because it returns the command line of the emulator itself, waiting for the user himself provide an additional command to terminate the emulator.
* commands have been implemented such as: HELP - to find out more command information; VERSION - to see the current version of the emulator; EXIT - to close the emulator and return to the operating system command line; All these 3 commands are processed by the routine "checkauxiliarcommands"
* New address arrays of command routines were needed, to facilitate the insertion of new commands; New strings were also implemented, to help the user to know the available commands;
* The program can now display the address of unknown instructions in addition to the instruction itself. However, when enabling all initial "comparisons" of which opcode is being read, no opcode becomes "unknown" as it is isolated by "AND" and goes from 0 to F, which possibly any nibble (4 bits) from the ASCII table will be between this range.


## Updates v1.1.0:

- Inclusion of "user16.inc" file with new seek, read, close, get_argc, get_argv, get_argv_str functions.
- Execution of SXE files directly from the command line (optional).
- `--help` and `--version` parameters directly on the command line (optional).
- error handling for file reading function.
- Functions to get file size, argument count and argument strings.
