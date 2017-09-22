\ These words control the manipulation of Unix processes and
\ convert actors into executable forms.

require files.fth

\ These words allow examination of child processes.
\c #include <sys/wait.h>
c-function cwait wait a -- n

variable status
: wait ( -- n ) status cwait ?err ;
: stat ( -- n ) status @ 8 rshift 255 and ;
: sig ( -- n ) status @ 255 and ;

\c #include <unistd.h>
c-function cexecvp execvp a a -- n
c-function cfork fork -- n

: fork ( -- n ) cfork ?err ;

\ The exec() system calls require a pointer to a list of null
\ terminated string pointers that is itself null terminated.
\ This is a tiresome conversion from an actor's character
\ buffer. The buffer must be crawled to collect a pointer
\ to each of the null terminated strings.

: >null ( a -- a+u ) begin 1+ dup c@ 0= until ;
: >field >null 1+ ;
: iter ( a -- a+u a )
  dup >buf swap >len @ bounds ;
: #fields ( a -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;

\ a2 is the address where to store the list of string pointers.
\ It will usually be the pad.
: prep ( a1 a2 -- )
  over >buf rot #fields 0 do
    swap 2dup !
    cell+
    swap >field
  loop 2drop ;
: ready ( a1 a2 -- a1+u a2 )
  2dup prep swap >buf swap ;
: exec ( a1 a2 -- ) cexecvp ?err drop ;

\ Serially execute a process.
: run ( a -- ) pad ready exec ;
: stop ( -- n ) wait drop stat ;
: % ( a -- n ) fork 0= if run else drop stop then ;

\ These words construct pipelines. There are three. One to
\ enter a pipeline, one to continue, and one to exit.
\ They work by taking and leaving file pointers on the stack.

\ The pattern of implementation should be familiar to anyone
\ familiar with how pipelines are constructed in Unix. It
\ works because children inherit parent file descriptors. I
\ was not so familiar at the beginning and have attempted
\ to explain it for the benefit of myself and others.

\ If this is the child process, unify the write end of the
\ pipe with standard out and run the command.
\ Otherwise, close the write end and leave the read end on
\ the stack.
: >|| ( a -- fp )
  pipe fork 0= if
    fileno stout clone
    swap run
  else
    close nip
  then ;

\ If this is the child process, unify the read end of the
\ previous pipe with standard in and the write end of the
\ new with standard out.
\ Otherwise, leave the read end of the new pipe and close
\ the others.
: || ( a fp1 -- fp2 )
  pipe rot fork 0= if
    fileno stin clone
    fileno stout clone
    swap run
  else
    close close nip
  then ;

\ Copy pipe input to standard out.
: ||> ( a fp -- ) || tell ;
