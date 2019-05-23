include /usr/share/dpkg/pkg-info.mk

PACKAGE=pve-jslint

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb
DSC=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}.dsc

GITVERSION:=$(shell git rev-parse HEAD)
BUILDDIR ?= ${PACKAGE}-${DEB_VERSION_UPSTREAM}

all: ${DEB}

${BUILDDIR}: src debian
	rm -rf ${BUILDDIR}
	rsync -a src/ debian ${BUILDDIR}
	echo "git clone git://git.proxmox.com/git/pve-jslint.git\\ngit checkout $(GITVERSION)" > ${BUILDDIR}/debian/SOURCE

.PHONY: deb
deb: ${DEB}
${DEB}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -b -us -uc
	lintian ${DEB}

.PHONY: dsc
dsc: ${DSC}
${DSC}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -S -us -uc -d -nc
	lintian ${DSC}

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}

.PHONY: download
src/jslint.js download:
	wget -O src/jslint.js http://jslint.com/jslint.js

.PHONY: distclean clean
distclean: clean
clean:
	rm -rf *~ ${BUILDDIR} rhinoed_jslint.js *.deb *.dsc *.tar.gz *.changes *.buildinfo

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh -X repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch
