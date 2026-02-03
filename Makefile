PREFIX=/usr
BINDIR=$(PREFIX)/bin
SYSTEMD_USER_DIR=$(PREFIX)/lib/systemd/user

all:
	@echo "Nothing to build"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 scripts/cronless-run-task $(DESTDIR)$(BINDIR)/
	install -m 0755 scripts/cronless-manage-tasks $(DESTDIR)$(BINDIR)/
	install -m 0755 scripts/cronless-weekly-report $(DESTDIR)$(BINDIR)/

	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cronless-run-task
	rm -f $(DESTDIR)$(BINDIR)/cronless-manage-tasks
	rm -f $(DESTDIR)$(BINDIR)/cronless-weekly-report

.PHONY: all install uninstall