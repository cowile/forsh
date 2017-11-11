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

\ This code defines some generic unility functions for dealing
\ with null terminated strings (C strings).

: c!+ ( c a -- a+1 ) swap over c! 1+ ;
: ndash ( a -- a+1 ) [char] - swap c!+ ;
: mdash ( a -- a+1 ) ndash ndash ;
: null ( a -- ) 0 swap c! ;
: fin ( a -- ) null ;
: >null ( a -- a+u ) begin 1+ dup c@ 0= until ;
: <null ( a -- a-u ) begin 1- dup c@ 0= until ;

: 3dup dup 2over rot ;

\ This function converts a counted string into a null
\ terminated one for consumption by C libraries.
: move+term ( a1 a2 u -- )
  2dup + 0 swap c! move ;
: cstring ( a1 a2 u -- a2 u+1 )
  3dup move+term 1+ rot drop ;
