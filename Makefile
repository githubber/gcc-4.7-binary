HOME := ${HOME}
INSTALL_DIR = ${HOME}/gcc
PWD := ${PWD}

CORES=8

# for mac os x on first build of gcc
# this is to ensure gcc will know about the memory model
CC = clang
CXX = clang++

# Default target executed when no arguments are given to make.
default_target: all

all: gcc
	@echo ''
	@echo '---------------------------'
	@echo '  compiling complete'
	@echo '  remember to run: make install'
	@echo '  and to update your ~/.bash_profile '
	@echo '  PATH=${INSTALL_DIR}/bin:$$PATH '
	@echo '  DYLD_LIBRARY_PATH=${INSTALL_DIR}/lib:$$DYLD_LIBRARY_PATH'
	@echo '  export PATH'
	@echo '  export DYLD_LIBRARY_PATH'
	@echo '---------------------------'
	@echo ''

gmp: unpack
	@echo ''
	@echo '---------------------------'
	@echo '  gmp compiling'
	@echo '---------------------------'
	@echo ''
	cd gmp/build; \
		../configure --prefix=${INSTALL_DIR} --enable-cxx; \
		make -j ${CORES}; \
		make install;
	@echo ''
	@echo '---------------------------'
	@echo '  gmp compiled'
	@echo '---------------------------'
	@echo ''

mpfr: unpack gmp
	@echo ''
	@echo '---------------------------'
	@echo '  mpfr compiling'
	@echo '---------------------------'
	@echo ''
	cd mpfr/build; \
		../configure  --prefix=${INSTALL_DIR} \
		--with-gmp=${INSTALL_DIR};  \
		make -j ${CORES}; \
		make install;
	@echo ''
	@echo '---------------------------'
	@echo '  mpfr compiled'
	@echo '---------------------------'
	@echo ''

mpc: unpack gmp mpfr
	@echo ''
	@echo '---------------------------'
	@echo '  mpc compiling'
	@echo '---------------------------'
	@echo ''
	cd mpc/build; \
		../configure --prefix=${INSTALL_DIR} \
		--with-gmp=${INSTALL_DIR} \
		--with-mpfr=${INSTALL_DIR}; \
		make -j ${CORES}; \
		make install;
	@echo ''
	@echo '---------------------------'
	@echo '  mpc compiled'
	@echo '---------------------------'
	@echo ''

ppl: unpack gmp
	@echo ''
	@echo '---------------------------'
	@echo '  ppl compiling'
	@echo '---------------------------'
	@echo ''
	cd ppl/build; \
		../configure --prefix=${INSTALL_DIR} \
		--with-gmp-prefix=${INSTALL_DIR}; \
		make -j ${CORES}; \
		make install;
	@echo ''
	@echo '---------------------------'
	@echo '  ppl compiled'
	@echo '---------------------------'
	@echo ''

cloog: unpack gmp ppl
	@echo ''
	@echo '---------------------------'
	@echo '  cloog compiling'
	@echo '---------------------------'
	@echo ''
	cd cloog/build; \
		../configure --prefix=${INSTALL_DIR} \
		--with-gmp=${INSTALL_DIR} \
		--with-ppl=${INSTALL_DIR}; \
		make -j ${CORES}; \
		make install;
	@echo ''
	@echo '---------------------------'
	@echo '  cloog compiled'
	@echo '---------------------------'
	@echo ''

gcc: unpack gmp ppl cloog mpfr mpc
	@echo ''
	@echo '---------------------------'
	@echo '  gcc compiling'
	@echo '---------------------------'
	@echo ''
	cd gcc/build; \
		../configure --prefix=${INSTALL_DIR} \
		--enable-checking=release \
		--with-gmp=${INSTALL_DIR} \
		--with-mpfr=${INSTALL_DIR} \
		--with-mpc=${INSTALL_DIR} \
		--with-ppl=${INSTALL_DIR} \
		--with-cloog=${INSTALL_DIR} \
		--enable-languages=c,c++,fortran; \
		make -j ${CORES};
	@echo ''
	@echo '---------------------------'
	@echo '  gcc compiled'
	@echo '---------------------------'
	@echo ''

unpack: fetch
	@echo ''
	@echo '---------------------------'
	@echo '  unpacking sources'
	@echo '---------------------------'
	@echo ''
	if [ ! -d ./gmp ]; then \
		tar jxvf gmp*.bz2; \
		mv gmp*/ gmp; \
		mkdir gmp/build; \
	fi
	if [ ! -d ./mpc ]; then \
		tar zxvf mpc*.gz; \
		mv mpc*/ mpc; \
		mkdir mpc/build; \
	fi
	if [ ! -d ./mpfr ]; then \
		tar jxvf mpfr*.bz2; \
		mv mpfr*/ mpfr; \
		mkdir mpfr/build; \
	fi
	if [ ! -d ./gcc ]; then \
		tar jxvf gcc*.bz2; \
		mv gcc*/ gcc; \
		mkdir gcc/build; \
	fi
	if [ ! -d ./cloog ]; then \
		tar zxvf cloog-ppl*.tar.gz; \
		mv cloog-ppl*/ cloog; \
		mkdir cloog/build; \
	fi
	if [ ! -d ./ppl ]; then \
		tar zxvf ppl*.tar.gz; \
		mv ppl*/ ppl; \
		mkdir ppl/build; \
	fi
	if [ ! -d ${INSTALL_DIR} ]; then \
		mkdir ${INSTALL_DIR}; \
	fi
	if [ ! -d ./build ]; then \
		mkdir build; \
	fi
	@echo ''
	@echo '---------------------------'
	@echo '  all unpacked'
	@echo '---------------------------'

fetch:
	@echo ''
	@echo '---------------------------'
	@echo '  downloading sources'
	@echo '---------------------------'
	@echo ''
	if \
		[[ ! -f gmp*.bz2 ]] || \
		[[ ! -f mpfr*.bz2 ]] || \
		[[ ! -f mpc*.gz ]] || \
		[[ ! -f gcc*.bz2 ]] || \
		[[ ! -f cloog-ppl*.gz ]] \
		|| [[ ! -f ppl*.gz ]]; \
		then \
		cat urls.txt | xargs -n1 -P 10 wget -nc; \
	fi
	@echo ''
	@echo '---------------------------'
	@echo '  sources downloaded'
	@echo '---------------------------'
	@echo ''

install:
	cd gcc/build; make install

# Clean Targets
clean:
	rm -rf gmp mpc mpfr ppl cloog-ppl gcc ${PWD}/build

clean-all: clean
	rm -rf *.bz2 *.gz ${INSTALL_DIR}

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... clean (removes source directories)"
	@echo "... clean-all (removes source directories and tarballs)"
	@echo "... cloog"
	@echo "... fetch"
	@echo "... gcc"
	@echo "... gmp"
	@echo "... install"
	@echo "... mpc"
	@echo "... mpfr"
	@echo "... ppl"
	@echo "... unpack"
