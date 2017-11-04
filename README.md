# Forsh

## Description

Forsh is a shell built on top of Gforth. It allows one to easily operate a Unix-like OS without leaving the gforth environment and can serve as a fully featured replacement to the Bourne Shell and derivatives such as Bash.

## Support

Forsh should run on any unix-like operating system supported by Gforth.

## Building

Forsh depends on Gforth and libtool. Whatever version is provided by the package manager should be fine.

Download the source code. Run make. Note that the makefile assumes some standard locations. For example, Gforth is located at /usr/bin/gforth. If this is not the case, run make GFORTH=/path/to/gforth.

To install, run make install as root.

## Introduction

/bin/sh has long been the trusty workhorse of the unix world. It provides many convenient features that give power to the user of the operating system, but programmers have often lamented that it does not behave like their favorite programming language. New users are easily confused by the slew of metacharacters, quoting, substitutions, and syntaxes.

Forsh is an experiment in shell design. Can a unix shell keep the power and usefulness of /bin/sh while remaining embedded in a consistent and general programming environment?

An understanding of Forth is beyond the scope of this document, but is extremely helpful for understanding how to use the environment to the fullest and provides insight into design choices.

## Basic Use

Commands are constructed incrementally in text buffers called actors. The global variable stage points to the actor currently in use.

The human interface words for constructing commands are very brief in the interest of human typing. The main ones are c, s, l, and p. c clears the current actor and reads in the program name of the new command. s reads in a block of short options. l reads in a single long option. p reads in a positional argument to the program.

Thus, `c progname s so l longopt p filename` is equivalent to `progname -so --longopt filename`.

Though slightly more verbose, the Forsh version avoids the need to type `-` all the time.

Here we come to a significant difference. /bin/sh executes the command on hitting the enter key. Forsh makes execution more explicit. The construction commands, when executed, only construct the command on the stage. The `$` word executes the command pointed to by stage. `%` does the same, but executes in the background rather than waiting for the command to finish.

`c ls $` executes the `ls` program. A side effect of the separation of construction from execution is that commands stick around after being executed. Executing the same command again is as simple as typing `$` again.

## Pipelines and IO Redirection

There are 5 words for building pipes, >|, |, |>, f>|, |>f. >| enters a pipe. | continues a pipe. |> exits a pipe. The f variants perform like the analogous pipe words but read and write files instead of standard in and standard out. Like `$`, these words execute the current command. The reason for so many is that the words work by passing around file pointers on the Forth stack. This adds power as it is easy to interface external processes with Forth code that reads and writes files.

More examples, `c ls >| c grep p txt$ |>` is equivalent to `ls | grep txt$`.
`c ls s" filename" |>f` is equivalent to `ls > filename`.
