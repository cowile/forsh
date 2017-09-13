variable stage
variable sep
bl sep !

: new ( u "name" -- ) create 0 , allot does> stage ! ;
: >len ;
: +len ( addr u -- ) swap >len +! ;
: >buf cell+ ;
: clear ( addr -- ) >len 0 swap ! ;

: start ( addr -- addr+u ) dup >len @ + >buf ;
: hyphen ( addr -- ) [char] - swap c! ;
: dash ( addr -- addr+1 ) dup hyphen 1+ ;
: mdash ( addr -- addr+1 ) dash dash ;
: null ( addr -- ) 0 swap c! ;
: fin ( addr -- ) null ;

: sflag ( addr c -- )
  over
  start dash
  dup -rot c! 1+
  fin
  3 +len ( length of -?\0 ) ;

: lflag ( addr1 addr2 u -- )
  >r >r dup
  start mdash
  dup r> swap r@ cmove r@ +
  fin
  r> 3 + +len ( length of --*\0 ) ;

: parg ( addr1 addr2 u -- )
  >r >r dup
  start
  dup r> swap r@ cmove r@ +
  fin
  r> 1+ +len ;

: cmd parg ;

: sf ( addr "char" -- ) char sflag ;
: lf ( addr "string" -- ) sep @ word count lflag ;
: pa ( addr "string" -- ) sep @ word count parg ;
: co pa ;

: s stage @ sf ;
: l stage @ lf ;
: p stage @ pa ;
: c p ;

128 new testbuf
testbuf
c program
stage @ char a sflag
s b
stage @ s" long" lflag
l longer
stage @ s" file" parg
p /usr/share/longfile
stage @ >len ?
stage @ >buf 64 type cr

: iter ( addr -- addr+u addr )
  dup >buf swap >len @ bounds ;
: >null ( addr -- addr+u ) begin dup c@ 0<> while 1+ repeat ;
: #null ( addr -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;
: >field >null 1+ ;

: prep ( addr1 addr2 -- )
  over >buf rot #null 0 do
    swap 2dup !
    cell+
    swap >field
  loop 2drop ;

: ready ( addr1 addr2 -- addr1+u addr2 )
  2dup prep swap >buf swap ;

stage @ #null . cr
stage @ pad ready
pad 8 cells dump cr

\c #include <unistd.h>
c-function exec execvp a a -- n

: run stage @ pad ready exec ;

64 new t
t
c touch p newfile run
