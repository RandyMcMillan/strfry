CC=c++
CFLAGS = -Wall -O2 -Ideps/secp256k1/include
OBJS = src/RelayCron.o src/RelayIngester.o src/RelayReqMonitor.o src/RelayReqWorker.o src/RelayWebsocket.o src/RelayWriter.o src/RelayYesstr.o src/cmd_export.o src/cmd_import.o src/cmd_info.o src/cmd_monitor.o src/cmd_relay.o src/cmd_scan.o src/cmd_stream.o src/cmd_sync.o src/events.o
HEADERS = deps/secp256k1/include/secp256k1.h src/ActiveMonitors.h src/RelayServer.h src/ThreadPool.h src/WriterPipeline.h src/events.h src/yesstr.h src/DBScan.h src/Subscription.h src/WSConnection.h src/constants.h src/filters.h

PREFIX ?= /usr/local
ARS = libsecp256k1.a
SUBMODULES = deps/secp256k1

BIN = strfry
OPT = -O3 -g
LDLIBS += -lsecp256k1 -lb2
STD=-std=c++2a


PERL=$(shell command -v perl)
export PERL
CPANM=$(shell command -v cpanm)
export CPANM

config.h: configurator##
	./configurator > $@

configurator: configurator.c##
	$(CC) $< -o $@

deps/secp256k1/.git:##
	@devtools/refresh-submodules.sh $(SUBMODULES)

deps/secp256k1/include/secp256k1.h: deps/secp256k1/.git##

deps/secp256k1/configure: deps/secp256k1/.git##
	cd deps/secp256k1; \
	./autogen.sh

deps/secp256k1/config.log: deps/secp256k1/configure##
	cd deps/secp256k1; \
	./configure --disable-shared --enable-module-ecdh --enable-module-schnorrsig --enable-module-extrakeys

deps/secp256k1/.libs/libsecp256k1.a: deps/secp256k1/config.log##
	cd deps/secp256k1; \
	make -j libsecp256k1.la

libsecp256k1.a: deps/secp256k1/.libs/libsecp256k1.a##
	cp $< $@

%.o: %.c $(HEADERS)##
	@echo "cc $<"
	@$(CC) $(CFLAGS) -c $< -o $@

install: install-all##

install-all:cpanm-install##

cpanm-install:##
	@test $(CPANM) && \
		sudo $(CPANM) YAML && \
		sudo $(CPANM) Test::LeakTrace && \
		sudo $(CPANM) Template && \
		echo "" || echo -e "install cpanm for easy setup...\nsudo apt-get install cpanminus\nOR\nbrew install cpanm"
	@type -P brew && brew install cpanminus || echo
	@type -P apt-get && sudo apt-get install -y cpanminus || echo

env:##
	@env -i $(PERL) -V

local-lib:##
	@$(CPANM) --local-lib=~/perl5 local::lib && eval $($PERL -I ~/perl5/lib/perl5/ -Mlocal::lib)

#NOTE:  STD=-std=c++2a make stuff macos x86_64
stuff: $(HEADERS) $(OBJS) $(ARS)##
	$(CC) $(CFLAGS) $(OBJS) $(ARS) -o $@

-include golpe/rules.mk

LDLIBS += -lsecp256k1 -lb2 -lzstd
