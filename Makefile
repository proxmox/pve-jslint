RELEASE=3.4

PACKAGE=pve-jslint
VERSION=1.0
PACKAGERELEASE=4

PKGREL=${VERSION}-${PACKAGERELEASE}
DEB=${PACKAGE}_${PKGREL}_all.deb
GITVERSION:=$(shell cat .git/refs/heads/master)

all: ${DEB}

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}

.PHONY: deb
deb: ${DEB}
${DEB}:
	make clean
	rm -rf dest
	mkdir dest
	make DESTDIR=`pwd`/dest install
	mkdir dest/DEBIAN
	sed -e 's/@PKGREL@/${PKGREL}/' <control.in >dest/DEBIAN/control
	mkdir -p dest/usr/share/doc/${PACKAGE}
	echo "git clone git://git.proxmox.com/git/pve-jslint.git\\ngit checkout ${GITVERSION}" > dest/usr/share/doc/${PACKAGE}/SOURCE
	install -m 0644 copyright dest/usr/share/doc/${PACKAGE}
	install -m 0644 changelog.Debian dest/usr/share/doc/${PACKAGE}
	gzip -n --best dest/usr/share/doc/${PACKAGE}/changelog.Debian
	fakeroot dpkg-deb --build dest
	mv dest.deb ${DEB}
	rm -rf dest
	lintian ${DEB}	

rhinoed_jslint.js: jslint.js rhino.js
	cat jslint.js rhino.js >$@.tmp
	mv $@.tmp $@

install: rhinoed_jslint.js jslint
	mkdir -p ${DESTDIR}/usr/share/${PACKAGE}
	install -m 0644 rhinoed_jslint.js ${DESTDIR}/usr/share/${PACKAGE}/rhinoed_jslint.js
	mkdir -p ${DESTDIR}/usr/bin
	install -m 0755 jslint ${DESTDIR}/usr/bin

jslint.js download:
	wget -O jslint.js http://jslint.com/jslint.js

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ dest control rhinoed_jslint.js *.deb

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro
