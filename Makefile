BIN = strfry
OPT = -O3 -g
LDLIBS += -lsecp256k1 -lb2

PERL=$(shell command -v perl)
export PERL
CPANM=$(shell command -v cpanm)
export CPANM

install: install-all
install-all:cpanm-install
cpanm-install:
	@test $(CPANM) && $(CPANM) YAML || echo -e "install cpanm for easy setup...\nsudo apt-get install cpanm\nOR\nbrew install cpanm"
env:
	@env -i $(PERL) -V
local-lib:
	@$(CPANM) --local-lib=~/perl5 local::lib && eval $($PERL -I ~/perl5/lib/perl5/ -Mlocal::lib)

include golpe/rules.mk

LDLIBS += -lsecp256k1 -lb2 -lzstd
