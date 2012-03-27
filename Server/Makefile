UNAME:=$(shell uname)

-include $(UNAME).min

GHC_FLAGS+=-Wall -Werror -threaded -fno-warn-orphans

RUN_TESTS := $(wildcard *Test.hs) $(wildcard */*Test.hs)

UNAME_S := $(shell uname -s)

TARGET = $(UNAME_S)
FLAVOR = Debug

V = $(TARGET)_$(FLAVOR)

all: $V/ship/icontrib $V/ship/libcryptopp.dylib $V/ship/import

$V/ship/icontrib: Main.hs Site.hs test
	@mkdir -p $(@D)
	ghc $(GHC_FLAGS) -outputdir $V -o $@ --make $<

$V/ship/libcryptopp.dylib:libcryptopp.dylib
	@mkdir -p $(@D)
	cp $< $@

libcryptopp.dylib:/usr/local/Cellar/cryptopp/5.6.1/lib/libcryptopp.a
	@mkdir -p $(@D)
	g++  -fpic -nostartfiles -nostdlib -shared $< -o $@

/usr/local/Cellar/cryptopp/5.6.1/lib/libcryptopp.a:
	brew install cryptopp #for ssl

# TODO: Replace this with a proper dependency scanner: "ghc -M"
$(foreach n,$(RUN_TESTS),$(eval $(patsubst %,$V/%.passed,$n): $n libcryptopp.dylib))

test: $(patsubst %,$V/%.passed,$(RUN_TESTS))

$V/%.passed:
	@mkdir -p $(@D)
	@echo Testing: $<
	@runghc $(GHC_FLAGS) $<
	@touch $@

clean:
	rm -rf libcryptopp.dylib #cant seem to point runghc to the right version
	rm -rf $V
	rm -rf dist

dist:
	cabal configure
	cabal build

deps:
	cabal update
	cabal install --only-dependencies

$V/ship/import: import.hs Data/*.hs
	@mkdir -p $(@D)
	ghc $(GHC_FLAGS) -outputdir $V -o $@ --make $<

