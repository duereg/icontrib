UNAME:=$(shell uname)
FLAVOR = Debug
V = $(UNAME)_$(FLAVOR)

LUA_DIR=../lua-5.2.0/$V/ship
JSL_DIR=../jsl/$V

all: lint $V/ship/IContrib.js

clean:
	rm -rf $V

JS_WHITELIST:= \
    js/json2.js \

JS_FILES:=$(filter-out $(JS_WHITELIST),$(wildcard *.js) $(wildcard */*.js))

lint: $(patsubst %,$V/%.ok,$(JS_FILES))

$V/%.js.ok: %.js
	@echo Linting: $<
	@$(JSL_DIR)/jsl -nologo -nofilelisting -nosummary -output-format "$*.js:__LINE__:__COL__: __ERROR__" -process $<
	@mkdir -p $(@D)
	@touch $@

$V/ship/IContrib.js: JsCache.lua $(filter-out yoink/%.js,$(filter-out test/%.js,$(filter-out %Test.js,$(JS_FILES))))
	@mkdir -p $(@D)
	$(LUA_DIR)/lua JsCache.lua -o $@ $(filter-out $<,$^)
