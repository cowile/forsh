\ This code defines the interface words that make forsh
\ convenient as an interactive shell. These words mainly take
\ user input and settings and leave the heavy lifting to more
\ programmatic and general words. They are very short for
\ easy typing.

require processes.fth

\ word has a limit of 255 character string, but no one should
\ ever need to type that much.
variable sep
: get sep @ word count ;
: sf ( a "string" -- ) char swap sflag ;
: lf ( a "string" -- ) get rot lflag ;
: pa ( a "string" -- ) get rot parg ;
: co pa ;

\ These correspond to sflag, lflag, and parg.
: s stage @ sf ;
: l stage @ lf ;
: p stage @ pa ;

\ Because program names are always first, a new program name
\ clears the current actor.
: cl stage @ clear ;
: c cl p ;

\ Execute a program, replacing the current shell.
: go ( -- ) cr stage @ run ;

\ Execute a program and wait for it to complete.
: $ ( -- n ) cr stage @ % ;

\ Execute a program and pipe to other programs.
: >| ( -- fp ) stage @ >|| ;
: | ( fp1 -- fp2 ) stage @ swap || ;
: |> ( fp -- ) stage @ swap ||> ;

\ Pipe from and to files.
: f>| ( a u -- fp ) r/o open-file ?err drop ;
: |>f ( fp a u -- ) w/o create-file ?err drop copy ;
