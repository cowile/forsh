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
\ This code defines the interface words that make forsh
\ convenient as an interactive shell. These words mainly take
\ user input and settings and leave the heavy lifting to more
\ programmatic and general words. They are very short for
\ easy typing.

require environment.fth
require processes.fth

: sf ( c -- ) stage @ sflag ;
: lf ( a u -- ) stage @ lflag ;
: pa ( a u -- ) stage @ parg ;
: na ( n -- ) stage @ narg ;
: co pa ;

\ Take an argument directly from an environment variable.
: earg ( a1 u a2 -- )
  -rot getenv rot parg ;
: ea ( a u -- ) stage @ earg ;

\ word has a limit of 255 character string, but no one should
\ ever need to type that much.
variable sep
: get sep @ word count ;
: s char sf ;
: l get lf ;
: p get pa ;
: e get earg ;
: sc 0 do s loop ;
: lc 0 do l loop ;
: pc 0 do p loop ;

\ Because program names are always first, a new program name
\ clears the current actor.
: cl stage @ clear ;
: c cl p ;

\ This is a quoted parg. It changes the separator to the next
\ character in the stream, then changes it back after getting
\ the field.
\ Example, q " this has spaces"
: quote ( xt "s" -- ) sep @ char sep ! execute sep ! ;
: q ['] p quote ;

\ Changing a directory has to be a shell function Unix prevents
\ programs from changing parents' working directories.
: d ( "s" -- ) get chdir ;
: qd ['] d quote ;
: up s" .." chdir ;
: ge ( "s" -- a ) get getenv ;
: se ( a u "s" -- ) get setenv ;
: ue ( "s" -- ) get unsetenv ;
: ce ( -- ) clearenv ;

: [get] sep @ parse postpone sliteral ; immediate

: [s] postpone [char] postpone sf ; immediate
: [l] postpone [get] postpone lf ; immediate
: [p] postpone [get] postpone pa ; immediate
: [c] postpone cl postpone [p] ; immediate
: [q] ['] [p] quote ; immediate
: [e] postpone [get] postpone ea ; immediate

: b stage @ back ;
: bc ( u -- ) 0 do b loop ;
: pr stage @ show ;

\ Execute a program, replacing the current shell.
: go ( -- ) cr stage @ run ;

\ Execute a program and wait for it to complete.
: $ ( -- n ) stage @ $$ drop ;

\ Execute a program in the background.
: & ( -- ) stage @ && ;

\ Execute a program and pipe to other programs.
: >| ( -- fp ) stage @ >|| ;
: | ( fp1 -- fp2 ) stage @ swap || ;
: |> ( fp -- ) stage @ swap ||> drop ;

\ Pipe from and to files.
: f>| ( a u -- fp ) r/o open-file ?err drop ;
: |>f ( fp a u -- ) w/o create-file ?err drop copy stop drop ;

\ This code defines functions to accomplish the same thing
\ as shell globbing by providing ready-made pipelines with
\ find and xargs. Example: s" *" match p cp p * p dir |>

\ a1 u1 is the pattern to search for. a2 u2 is a predicate
\ for the find command. u3 is the maximum search depth.
bl sep !
: match ( a1 u1 a2 u2 u3 -- )
  [c] find [p] . [p] -maxdepth na pa pa [p] -exec ;
: pmatch s" -path" rot match ;
: fmatch s" -name" rot match ;
: m 1 fmatch ;

\ Set up the outer loop.
\ The word prompt was already taken by gforth.
defer 'cue
: shell 'cue begin refill while cr interpret 'cue repeat ;
' shell is 'quit
