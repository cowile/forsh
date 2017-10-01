DEST = /usr/bin
GFORTH = /usr/bin/gforth
GSHARE = /usr/share/gforth/site-forth
PROG = forsh
INSTALL = \
	$(GSHARE)/actors.fth \
	$(GSHARE)/environment.fth \
	$(GSHARE)/errors.fth \
	$(GSHARE)/files.fth \
	$(GSHARE)/forsh.fth \
	$(GSHARE)/interface.fth \
	$(GSHARE)/processes.fth \
	$(GSHARE)/strings.fth \
	$(GSHARE)/tests.fth

.POSIX:
.PHONY: all clean install uninstall

all: $(PROG)

clean:
	rm $(PROG)

install: all $(INSTALL)
	install $(PROG) $(DEST)/$(PROG)

uninstall:
	rm $(INSTALL) $(DEST)/$(PROG)

$(PROG):
	printf "#! %s\nrequire forsh.fth\n" $(GFORTH) >$@

$(GSHARE)/%.fth: %.fth
	install -m 0644 $< $@
