UUID    := openvpn3-switcher@djlechuck
DOMAIN  := openvpn3-switcher
DEST    := $(HOME)/.local/share/gnome-shell/extensions/$(UUID)
LANGS   := $(basename $(notdir $(wildcard po/*.po)))

.PHONY: install uninstall

# Manual install for non-Nix users. Log out/in (Wayland) afterwards, then:
#   gnome-extensions enable $(UUID)
install:
	install -Dm644 metadata.json $(DEST)/metadata.json
	install -Dm644 extension.js $(DEST)/extension.js
	@for lang in $(LANGS); do \
		mkdir -p $(DEST)/locale/$$lang/LC_MESSAGES; \
		msgfmt po/$$lang.po -o $(DEST)/locale/$$lang/LC_MESSAGES/$(DOMAIN).mo; \
	done

uninstall:
	rm -rf $(DEST)
