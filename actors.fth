\ Copyright 2017 Colton Lewis
\
\ Licensed under the Apache License, Version 2.0 (the "License");
\ you may not use this file except in compliance with the License.
\ You may obtain a copy of the License at
\
\     http://www.apache.org/licenses/LICENSE-2.0
\
\ Unless required by applicable law or agreed to in writing, software
\ distributed under the License is distributed on an "AS IS" BASIS,
\ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
\ See the License for the specific language governing permissions and
\ limitations under the License.
\
\ This file defines the words used for manipulating actors.
\ Actors are implemented as a 1 cell length field followed
\ by a character buffer with size determined by the caller.
\ The buffer holds a sequence of null terminated strings that
\ represent the command and it's arguments.

require strings.fth

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

\ Store the option string at a2. All option strings are null
\ terminated because null is used as a string terminator for
\ compatibility with C strings.
: option ( a1 u a2 -- )
  3dup swap move + fin drop ;

\ Store a '-c' style argument.
: sflag ( a1 u a2 -- )
  3dup
  start ndash option
  swap 2 + +len drop ;

\ Store a '--long-flag' style argument.
: lflag ( a1 u a2 -- )
  3dup
  start mdash option
  swap 3 + +len drop ;

\ Store a plain positional argument.
: parg ( a1 u a2 -- )
  3dup
  start option
  swap 1+ +len drop ;

\ Store a command the same way as a positional argument.
: cmd parg ;

\ Store a number on the stack as a positional argument.
: narg ( n a -- )
  swap s>d <# #s #> rot parg ;

\ Calculate the bounds for iterating over an actor
\ in a do loop.
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

: >field >null 1+ ;
: <field 1- <null 1+ ;

\ Delete the most recently added field.
\ There is no input validation. Garbage in, garbage out.
: back ( a -- )
  dup start <field
  over >buf -
  swap >len ! ;
