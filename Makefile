PREFIX=/usr
BINDIR=$(PREFIX)/bin
SYSTEMD_USER_DIR=$(PREFIX)/lib/systemd/user

all:
	@echo "Nothing to build"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 scripts/cronless $(DESTDIR)$(BINDIR)/
	install -m 0755 scripts/cronless-report $(DESTDIR)$(BINDIR)/

	ln -sf cronless $(DESTDIR)$(BINDIR)/cl

	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cronless
	rm -f $(DESTDIR)$(BINDIR)/cronless-report
	rm -f $(DESTDIR)$(BINDIR)/cl

.PHONY: all install uninstall
