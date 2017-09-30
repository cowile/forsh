variable #io
1024 #io !
variable io
pad io !

: iobuf ( fp -- a u fp ) io @ 1024 rot ;
: rin ( fp -- ) iobuf read-file drop ;

s" file" r/o open-file drop rin
