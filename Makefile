# Project makefile for git-weave

VERS=$(shell sed <git-weave -n -e '/^version *= *"\(.*\)"/s//\1/p')

SOURCES = README COPYING NEWS git-weave git-weave.txt git-weave.1 Makefile \
	control git-weave-logo.png

all: git-weave.1

.SUFFIXES: .html .txt .1

# Requires asciidoc and xsltproc/docbook stylesheets.
.txt.1:
	a2x --doctype manpage --format manpage -D . $<
.txt.html:
	a2x --doctype manpage --format xhtml -D . $<

clean:
	rm -f *~ *.1 *.html *.rpm *.lsm MANIFEST

install: git-weave.1 uninstall
	install -m 0755 -d $(DESTDIR)/usr/bin
	install -m 0755 -d $(DESTDIR)/usr/share/man/man6
	install -m 0755 -d $(DESTDIR)//usr/share/applications/
	install -m 0755 -d $(DESTDIR)/usr/share/pixmaps/
	install -m 0755 -d $(DESTDIR)/usr/share/appdata
	install -m 0755 git-weave $(DESTDIR)/usr/bin/
	install -m 0644 git-weave.1 $(DESTDIR)/usr/share/man/man6/
	install -m 0644 git-weave.xml $(DESTDIR)/usr/share/appdata/

uninstall:
	rm -f /usr/bin/git-weave /usr/share/man/man6/git-weave.1
	rm -f /usr/share/pixmaps/git-weave-logo.png

PYLINTOPTS = --rcfile=/dev/null --reports=n \
	--msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" \
	--dummy-variables-rgx='^_'
SUPPRESSIONS = "C0103,C0111,C0301,C0326,C1001,E1103,R0912,R0914,R0915,W0110,W0141,W0621,W0631"
pylint:
	@pylint $(PYLINTOPTS) --disable=$(SUPPRESSIONS) git-weave

check:
	cd tests; $(MAKE) --quiet

version:
	@echo $(VERS)

git-weave-$(VERS).tar.gz: $(SOURCES)
	@ls $(SOURCES) | sed s:^:git-weave-$(VERS)/: >MANIFEST
	@(cd ..; ln -s git-weave git-weave-$(VERS))
	(cd ..; tar -czf git-weave/git-weave-$(VERS).tar.gz `cat git-weave/MANIFEST`)
	@ls -l git-weave-$(VERS).tar.gz
	@(cd ..; rm git-weave-$(VERS))

dist: git-weave-$(VERS).tar.gz

release: git-weave-$(VERS).tar.gz git-weave.html
	shipper version=$(VERS) | sh -e -x

refresh: git-weave.html
	shipper -N -w version=$(VERS) | sh -e -x
