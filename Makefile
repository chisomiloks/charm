include ./config.mk

# user config options
setup1=$(shell mkdir -p /tmp/build-charm)
dest_build=/tmp/build-charm

# gmp source
gmp_version=gmp-5.0.2
gmp_url=http://ftp.gnu.org/gnu/gmp/${gmp_version}.tar.gz
gmp_options=

# pbc source
pbc_version=pbc-0.5.12
pbc_url=http://crypto.stanford.edu/pbc/files/${pbc_version}.tar.gz
pbc_options=
DESTDIR=${prefix}

all:
	@echo "make build - Build the charm framework and install dependencies."
	@echo "make source - Create source package."
	@echo "make install - Install on local system."
	@echo "make clean - Get rid of scratch and byte files."
	@echo "make test  - Run Unit Tests."

.PHONY: setup
setup:
	@echo "Setup build/staging directories"
	set -x
	${setup1}
	set +x

.PHONY: build-gmp
build-gmp:
	@echo "Building the GMP library"
	set -x
	if test "${HAVE_LIBGMP}" = "yes" ; then \
           echo "GMP installed already."; \
	elif [ ! -f ${gmp_version}.tar.gz ]; then \
	   wget ${gmp_url}; \
	   tar -zxf ${gmp_version}.tar.gz -C ${dest_build}; \
	   cd ${dest_build}/${gmp_version}; ./configure ${gmp_options} --prefix=${DESTDIR}; \
	   ${MAKE} install; \
	   echo "GMP install: OK"; \
        else \
	   tar -zxf ${gmp_version}.tar.gz -C ${dest_build}; \
	   cd ${dest_build}/${gmp_version}; ./configure ${gmp_options} --prefix=${DESTDIR}; \
	   ${MAKE} install; \
	   echo "GMP install: OK"; \
	fi
	set +x

.PHONY: build-pbc
build-pbc:
	@echo "Building the PBC library"
	set -x
	if test "${HAVE_LIBPBC}" = "yes" ; then \
	   echo "PBC installed already."; \
	elif [ ! -f ${pbc_version}.tar.gz ]; then \
	   wget ${pbc_url}; \
	   tar -zxf ${pbc_version}.tar.gz -C ${dest_build} \
	   cd ${dest_build}/${pbc_version}; ./configure ${pbc_options} --prefix=${DESTDIR}; \
	   ${MAKE} install; \
	   echo "PBC install: OK"; \
	else \
	   tar -zxf ${pbc_version}.tar.gz -C ${dest_build} \
	   cd ${dest_build}/${pbc_version}; ./configure ${pbc_options} --prefix=${DESTDIR}; \
	   ${MAKE} install; \
	   echo "PBC install: OK"; \
	fi
	set +x
	
.PHONY: build
build: setup build-gmp build-pbc
	@echo "Building the Charm Framework"
	$(PYTHON) setup.py build
	@echo "Complete"

#.PHONY: rebuild
#rebuild:
#	@echo "Building the Charm Framework"
#	${PYTHON} setup.py build
#	@echo "Complete"

.PHONY: source
source:
	$(PYTHON) setup.py sdist $(COMPILE)

.PHONY: install
install:
	$(PYTHON) setup.py install # $(COMPILE)
	
.PHONY: test
test:
	$(PYTHON) tests/all_unittests.py
	$(PYTHON) tests/all_schemes.py
	#find ./tests/ -name '*.py' -exec python3 '{}' \;

# .PHONY: buildrpm
# buildrpm:
#        $(PYTHON) setup.py bdist_rpm # --post-install=rpm/postinstall --pre-uninstall=rpm/preuninstall

# .PHONY: builddeb
# builddeb:
        # build the source package in the parent directory
        # then rename it to project_version.orig.tar.gz
#        $(PYTHON) setup.py sdist $(COMPILE) --dist-dir=../ --prune
#        rename -f 's/$(PROJECT)-(.*)\.tar\.gz/$(PROJECT)_$$1\.orig\.tar\.gz/' ../*
        # build the package
#        dpkg-buildpackage -i -I -rfakeroot

.PHONY: clean
clean:
	$(PYTHON) setup.py clean
#        $(MAKE) -f $(CURDIR)/debian/rules clean
	rm -rf build/ dist/ ${dest_build} MANIFEST
	find . -name '*.pyc' -delete


