variable stage
: new ( u "name" -- ) create 0 , allot ;
: actor ( u "name" -- ) new does> stage ! ;
: >len ;
: +len ( a u -- ) swap >len +! ;
: >buf cell+ ;
: clear ( a -- ) >len 0 swap ! ;

: start ( a -- a+u ) dup >len @ + >buf ;
: c!+ ( a c -- a+1 ) over c! 1+ ;
: ndash ( a -- a+1 ) [char] - c!+ ;
: mdash ( a -- a+1 ) ndash ndash ;
: null ( a -- ) 0 swap c! ;
: fin ( a -- ) null ;

: 3dup dup 2over rot ;
: lopt ( a1 u a2 -- )
  3dup swap cmove + fin drop ;
: sopt ( c a -- )
  swap c!+ fin ;

: sflag ( c a -- )
  dup -rot
  start ndash sopt
  3 +len ;
: lflag ( a1 u a2 -- )
  3dup
  start mdash lopt
  swap 3 + +len drop ;
: parg ( a1 u a2 -- )
  3dup
  start lopt
  swap 1+ +len drop ;
: cmd parg ;

variable sep
bl sep !
: get sep @ word count ;

: sf ( a "string" -- ) char swap sflag ;
: lf ( a "string" -- ) get rot lflag ;
: pa ( a "string" -- ) get rot parg ;
: co pa ;

: s stage @ sf ;
: l stage @ lf ;
: p stage @ pa ;
: c p ;
: cl stage @ clear ;

128 actor prog
prog
c program
char a stage @ sflag
s b
s" long" stage @ lflag
l longer
s" file" stage @ parg
p /usr/share/longfile
stage @ >len ?
stage @ >buf 55 type cr

: iter ( a -- a+u a )
  dup >buf swap >len @ bounds ;
: >null ( a -- a+u ) begin dup c@ 0<> while 1+ repeat ;
: >field >null 1+ ;
: #fields ( a -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;

: prep ( a1 a2 -- )
  over >buf rot #fields 0 do
    swap 2dup !
    cell+
    swap >field
  loop 2drop ;
: ready ( a1 a2 -- a1+u a2 )
  2dup prep swap >buf swap ;

stage @ #fields . cr
stage @ pad ready
pad 8 cells dump cr
2drop

: print ( a -- ) dup >null over - type ;

\c #include <errno.h>
c-function errno __errno_location -- a
\c #include <string.h>
c-function explain strerror n -- a

: report ( n -- ) cr explain print ;
: ?err ( -- )
  errno @ 0<> if
    errno @ report
  then
  0 errno ! ;

\c #include <sys/wait.h>
c-function cwait wait a -- n

variable status
: wait ( -- n ) status cwait ?err ;
: stat ( -- n ) status @ 8 rshift 255 and ;
: sig ( -- n ) status @ 255 and ;

\c #include <stdio.h>
c-function fdopen fdopen n a -- a

: fd>fp ( n1 c -- n2 ) pad swap c!+ fin pad fdopen ?err ;
: fd>ro ( n1 -- n2 ) [char] r fd>fp ;
: fd>wo ( n1 -- n2 ) [char] w fd>fp ;
: conv ( n1 -- n2 n3 )
  dup 32 rshift fd>wo
  swap 32 lshift 32 rshift fd>ro ;

\c #include <unistd.h>
c-function cexec execvp a a -- n
c-function cfork fork -- n
c-function cpipe pipe a -- n
c-function cdup2 dup2 n n -- n

: pipe ( -- n1 n2 )
  pad cpipe ?err drop pad @ conv ;
: read@ 2@ nip ;
: write@ 2@ drop ;

0 errno !
2variable line
pipe line 2!
line write@ close-file ?err drop
line read@ close-file ?err drop

: fork ( -- n ) cfork ?err dup -1 = if rdrop then ;
: exec ( a1 a2 -- ) cexec ?err drop ;
: run ( a -- ) pad ready exec ;
: go ( -- ) stage @ run ;
