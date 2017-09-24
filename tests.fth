\ This code conducts tests to sanity check all the code.
\ Inspection of results is conducted manually.

require forsh.fth

\ Declare an actor and build its command line arguments.
128 actor prog
prog
c program
char a stage @ sflag
s b
s" long" stage @ lflag
l longer
s" file" stage @ parg
p /usr/share/longfile
stage @ >len ? cr
stage @ >buf 55 type cr

\ Prepare an actor for execution and examine the array of
\ pointers to strings built on the pad.
stage @ #fields . cr
stage @ pad ready
pad 8 cells dump cr
2drop

\ Make sure anonymous pipes return valid file pointers.
0 errno !
2variable line
pipe line 2!
line write@ close
line read@ close

\ See if commands and pipelines work.
1 8 lshift #io !
36 actor def
def
c echo p hi $ drop
c echo p hello >| c cat |>
c echo p hello >| s" file" |>f
