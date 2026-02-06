PREFIX=/usr
BINDIR=$(PREFIX)/bin
SYSTEMD_USER_DIR=$(PREFIX)/lib/systemd/user

all:
	@echo "Nothing to build"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 scripts/cronless $(DESTDIR)$(BINDIR)/
	install -m 0755 scripts/cronless-weekly-report $(DESTDIR)$(BINDIR)/

	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cronless
	rm -f $(DESTDIR)$(BINDIR)/cronless-weekly-report

.PHONY: all install uninstall