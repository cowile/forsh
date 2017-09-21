variable stage
: new ( u "name" -- ) create 0 , allot ;
: actor ( u "name" -- ) new does> stage ! ;
: >len ;
: +len ( a n -- ) swap >len +! ;
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

: >null ( a -- a+u ) begin 1+ dup c@ 0= until ;
: >field >null 1+ ;
: iter ( a -- a+u a )
  dup >buf swap >len @ bounds ;
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

\c #include <errno.h>
c-function errno __errno_location -- a

: explain ( n -- ) strerror ;
: report ( n -- ) cr explain type ;
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
c-function cfdopen fdopen n a -- a
c-function cfileno fileno a -- n

: fdopen cfdopen ?err ;
: fileno cfileno ?err ;
: fd>fp ( fd c -- fp ) pad swap c!+ fin pad fdopen ;
: fd>ro ( fd -- fp ) [char] r fd>fp ;
: fd>wo ( fd -- fp ) [char] w fd>fp ;
: conv ( n -- fd1 fd2 )
  dup 32 lshift 32 rshift fd>ro
  swap 32 rshift fd>wo ;

\c #include <unistd.h>
c-function cexecvp execvp a a -- n
c-function cfork fork -- n
c-function cpipe pipe a -- n
c-function cdup2 dup2 n n -- n

: pipe ( -- fd1 fd2 )
  pad cpipe ?err drop pad @ conv ;
: read@ 2@ drop ;
: write@ 2@ nip ;
: wclose ( fd -- ) close-file ?err drop ;
: rclose ( fd -- ) close-file ?err drop ;

0 errno !
2variable line
pipe line 2!
line write@ wclose
line read@ rclose

0 constant stin
1 constant stout
2 constant sterr
: clone ( fd1 fd2 -- ) cdup2 ?err drop ;
: fork ( -- n ) cfork ?err dup -1 = if rdrop then ;
: exec ( a1 a2 -- ) cexecvp ?err drop ;
: run ( a -- ) pad ready exec ;
: go ( -- ) stage @ run ;
: stop ( -- n ) wait drop stat ;
: % ( a -- n ) fork 0= if run else drop stop then ;
: $ ( -- n ) stage @ % ;

variable #io
: iobuf ( fp -- a u fp ) pad #io @ rot ;
: rin ( fp -- ) iobuf read-file ?err drop ;
: wout ( fp -- ) iobuf write-file ?err drop ;
: copy ( fp1 fp2 -- )
  cr #io @ -rot
  begin
    over rin #io ! dup wout
  over file-eof? until
  2drop #io ! ;
: tell ( fp -- ) stdout copy ;
: wail ( fp -- ) stderr copy ;

: >|| ( a -- fp )
  pipe fork 0= if
    fileno
    stout clone swap run
  else
    wclose nip
  then ;
: || ( a fp1 -- fp2 )
  pipe rot fork 0= if
    fileno stin clone
    fileno stout clone
    swap run
  else
    rclose wclose nip
  then ;
: ||> ( a fp -- ) || tell ;

: >| ( -- fp ) stage @ >|| ;
: | ( fp1 -- fp2 ) stage @ swap || ;
: |> ( fp -- ) stage @ swap ||> ;
: f>| ( a u -- fp ) r/o open-file ?err drop ;
: |>f ( fp a u -- ) w/o create-file ?err drop copy ;

1 8 lshift #io !
36 actor def
def
c echo p hello >| cl c cat |>
cl c echo p hello >| s" file" |>f
