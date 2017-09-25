\ This file defines the words used for manipulating actors.
\ Actors are implemented as a 1 cell length field followed
\ by a character buffer with size determined by the caller.
\ The buffer holds a sequence of null terminated strings that
\ represent the command and it's arguments.

: new ( u "name" -- ) create 0 , allot ;
\ Stages are where actors do their thing. An actor word puts
\ itself on the stage when executed.
variable stage
variable #stage
: actor ( u "name" -- ) new does> stage ! ;
\ An act does things immediately when created.
: act ( "name" -- )
  create here stage ! 0 , #stage @ allot
  does> stage ! ;
\ This word exists to show when length is accessed even though
\ there is nothing to do.
: >len ;
: +len ( a n -- ) swap >len +! ;
: >buf cell+ ;
\ Don't bother clearing the characters. Length determines
\ whether data is valid.
: clear ( a -- ) >len 0 swap ! ;

\ These words construct the components of how unix commands
\ expect their command arguments to look. Nonstandard
\ syntax can always be handled with a positional argument.
\ start calculates the address to begin appending to a command.
: start ( a -- a+u ) dup >len @ + >buf ;
: c!+ ( c a -- a+1 ) swap over c! 1+ ;
: ndash ( a -- a+1 ) [char] - swap c!+ ;
: mdash ( a -- a+1 ) ndash ndash ;
: null ( a -- ) 0 swap c! ;
: fin ( a -- ) null ;

: 3dup dup 2over rot ;

\ Store the long option string at a2.
: lopt ( a1 u a2 -- )
  3dup swap move + fin drop ;

\ Store the short option character at a.
: sopt ( c a -- ) c!+ fin ;

\ Store a '-c' style argument.
: sflag ( c a -- )
  dup -rot
  start ndash sopt
  3 +len ;

\ Store a '--long-flag' style argument.
: lflag ( a1 u a2 -- )
  3dup
  start mdash lopt
  swap 3 + +len drop ;

\ Store a plain positional argument.
: parg ( a1 u a2 -- )
  3dup
  start lopt
  swap 1+ +len drop ;

\ Store a command the same way as a positional argument.
: cmd parg ;

: >null ( a -- a+u ) begin 1+ dup c@ 0= until ;
: >field >null 1+ ;
: iter ( a -- a+u a )
  dup >buf swap >len @ bounds ;
: show ( a -- )
  iter do
    i c@ dup
    0= if drop [char] , then
    emit
  loop ;
: #fields ( a -- u )
  0 swap
  iter do
    i c@ 0= if 1+ then
  loop ;
: clip ( n1 n2 n3 -- n4 ) rot min max ;
: >fields ( a u1 -- a+u2 ) 0 do >field loop ;
: field ( a u1 -- a+u2 )
  over #fields 0 swap clip
  swap >buf swap >fields ;
: back ( a u -- )
  over dup #fields
  rot - field
  over >buf -
  swap >len ! ;
