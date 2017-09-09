3 constant etx
variable stage
variable sep
bl sep !

: new ( u "name" -- ) create 0 , allot ;
: >len ;
: >buf cell+ ;
: jump ( addr -- addr+u ) dup >len @ + >buf ;

: dash ( addr -- ) [char] - swap c! ;
: flag ( addr -- ) char swap c! ;
: null ( addr -- ) 0 swap c! ;
: end ( addr -- ) etx swap c! ;
: fin ( addr -- ) null 1+ end ;
: grab ( "string" -- addr u ) sep @ word count ;

: sf ( addr "char" -- )
  dup
  dup jump
  dup dash 1+
  dup flag 1+
  dup fin
  >len 3 ( length of -?\0 ) swap +! ;

: lf ( addr "string" -- )
  dup
  dup jump
  dup dash 1+
  dup dash 1+
  dup grab >r swap r@ cmove r@ +
  dup fin
  >len r@ 3 + ( length of --*\0 ) swap +! r> ;

\c #include <unistd.h>
c-function exec execvp n n -- n
