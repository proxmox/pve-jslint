PACKAGE=pve-jslint
VERSION=1.0
PACKAGERELEASE=5

PKGREL=${VERSION}-${PACKAGERELEASE}
DEB=${PACKAGE}_${PKGREL}_all.deb
GITVERSION:=$(shell git rev-parse HEAD)

BUILDDIR ?= ${PACKAGE}-${VERSION}

all:

${BUILDDIR}: debian
	rm -rf ${BUILDDIR}
	rsync -a * ${BUILDDIR}
	echo "git clone git://git.proxmox.com/git/pve-jslint.git\\ngit checkout $(GITVERSION)" > ${BUILDDIR}/debian/SOURCE

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}

.PHONY: deb
deb: ${DEB}
${DEB}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -b -us -uc
	lintian ${DEB}

rhinoed_jslint.js: jslint.js rhino.js
	cat jslint.js rhino.js >$@.tmp
	mv $@.tmp $@

install: rhinoed_jslint.js jslint
	install -d -m 0755 ${DESTDIR}/usr/share/${PACKAGE}
	install -m 0644 rhinoed_jslint.js ${DESTDIR}/usr/share/${PACKAGE}/rhinoed_jslint.js
	install -d -m 0755 ${DESTDIR}/usr/bin
	install -m 0755 jslint ${DESTDIR}/usr/bin

jslint.js download:
	wget -O jslint.js http://jslint.com/jslint.js

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ ${BUILDDIR} rhinoed_jslint.js *.deb *.changes *.buildinfo

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh -X repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch
