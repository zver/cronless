PREFIX=/usr
BINDIR=$(PREFIX)/bin
SYSTEMD_USER_DIR=$(PREFIX)/lib/systemd/user

all:
	@echo "Nothing to build"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 scripts/cronless $(DESTDIR)$(BINDIR)/
	install -Dm644 cronless.zsh-completions \
		$(DESTDIR)$(PREFIX)/share/zsh/vendor-completions/_cronless
	install -Dm644 cronless.bash-completion \
    	$(DESTDIR)$(PREFIX)/share/bash-completion/completions/cronless

	ln -sf cronless $(DESTDIR)$(BINDIR)/cl

	install -d $(DESTDIR)$(SYSTEMD_USER_DIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/cronless
	rm -f $(DESTDIR)$(BINDIR)/cl

.PHONY: all install uninstall
