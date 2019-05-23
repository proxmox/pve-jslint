DESTDIR=
PACKAGE ?= pve-jslint

rhinoed_jslint.js: jslint.js rhino.js
	cat jslint.js rhino.js >$@.tmp
	mv $@.tmp $@

install: rhinoed_jslint.js jslint
	install -d -m 0755 ${DESTDIR}/usr/share/${PACKAGE}
	install -m 0644 rhinoed_jslint.js ${DESTDIR}/usr/share/${PACKAGE}/rhinoed_jslint.js
	install -d -m 0755 ${DESTDIR}/usr/bin
	install -m 0755 jslint ${DESTDIR}/usr/bin
