\ This code defines the interface words that make forsh
\ convenient as an interactive shell. These words mainly take
\ user input and settings and leave the heavy lifting to more
\ programmatic and general words. They are very short for
\ easy typing.

require directories.fth
require processes.fth

: sf ( c -- ) stage @ sflag ;
: lf ( a u -- ) stage @ lflag ;
: pa ( a u -- ) stage @ parg ;
: co pa ;

\ word has a limit of 255 character string, but no one should
\ ever need to type that much.
variable sep
: get sep @ word count ;
: s char sf ;
: l get lf ;
: p get pa ;
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
: quote ( xt "string" -- ) sep @ char sep ! execute sep ! ;
: q ['] p quote ;

\ Changing a directory has to be a shell function Unix prevents
\ programs from changing parents' working directories.
: d ( "string" -- ) get chdir ;
: qd ['] d quote ;
: up s" .." chdir ;

: geti sep @ parse postpone sliteral ; immediate
: [s] postpone [char] ['] sf compile, ; immediate
: [l] postpone geti ['] lf compile, ; immediate
: [p] postpone geti ['] pa compile, ; immediate
: [c] ['] cl compile, postpone [p] ; immediate
: [q] ['] q compile, postpone [p] ; immediate
: [d] postpone geti ['] chdir compile, ; immediate

: [sc] 0 do postpone [s] loop ; immediate
: [lc] 0 do postpone [l] loop ; immediate
: [pc] 0 do postpone [p] loop ; immediate

: bc ( u -- ) stage @ swap back ;
: b 1 bc ;
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

\ Set up the outer loop.
\ The word prompt was already taken by gforth.
defer cue
: shell cue begin refill while cr interpret cue repeat ;
' shell is 'quit
