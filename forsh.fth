variable stage
variable sep
bl sep !

: new ( u "name" -- ) create 0 , allot does> stage ! ;
: >len ;
: >buf cell+ ;
: start ( addr -- addr+u ) dup >len @ + >buf ;
: clear ( addr -- ) >len 0 swap ! ;

: hyphen ( addr -- ) [char] - swap c! ;
: dash ( addr -- addr+1 ) dup hyphen 1+ ;
: mdash ( addr -- addr+1 ) dash dash ;
: null ( addr -- ) 0 swap c! ;
: fin ( addr -- ) null ;

: sflag ( addr c -- )
  >r
  dup start
  dash
  dup r> swap c! 1+
  fin
  >len 3 ( length of -?\0 ) swap +! ;

: lflag ( addr1 addr2 u -- )
  >r >r
  dup start
  mdash
  dup r> swap r@ cmove r@ +
  fin
  >len r> 3 + ( length of --*\0 ) swap +! ;

: parg ( addr1 addr2 u -- )
  >r >r
  dup start
  dup r> swap r@ cmove r@ +
  fin
  >len r> 1+ swap +! ;

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

: prep ( addr1 addr2 -- addr3 addr4 )
  dup >r >r >buf
  begin
    dup c@ etx <>
  while
    dup r@ !
    r> cell+ >r
    >null 1+
  repeat
  0 r> ! r> dup @ swap ;

( stage @ pad prep
pad 8 cells dump cr

 \c #include <unistd.h>
c-function exec execvp n n -- n )
