TITLE=$(shell head -n 1 conf.fnl)
NAME=$(shell echo $(TITLE) | tr '[:upper:]' '[:lower:]')
LIBS=$(shell tail -n 1 conf.fnl)
VERSION=0.0.0
LOVE_VERSION=11.5
ITCH_ACCOUNT=thedotmatrix
URL=https://github.com/thedotmatrix/fennel-and-love2d
AUTHOR="Dot Matrix"
DESCRIPTION="fennel-and-love2d game console"
ALL := $(wildcard *.lua *.fnl)
# FIXME redux file structure
AST := $(wildcard assets/*.* 		src/$(NAME)/assets/*.*		src/$(NAME)/assets/*/*.*)
CLS := $(wildcard classes/*.fnl 	src/$(NAME)/classes/*.fnl)
CRT := $(wildcard cartridges/*.fnl 	src/$(NAME)/cartridges/*.fnl)
LIB := $(foreach L,$(LIBS),$(wildcard lib/$L.*))
MAC := $(wildcard mac/*.fnl)

run: ; love .

count: ; cloc *.fnl

clean: ; rm -rf bin/*

LOVEFILE=bin/$(TITLE)-$(VERSION).love

$(LOVEFILE): $(ALL) $(AST) $(CLS) $(CRT) $(LIB) $(MAC)
	mkdir -p bin/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL=$(PWD)/bld/love-release.sh # https://p.hagelb.org/love-release.sh
FLAGS=-t "$(TITLE)" -a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love $(LOVE_VERSION) --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

bin/$(TITLE)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd bld/appimage && \
	./build.sh $(LOVE_VERSION) $(PWD)/$(LOVEFILE) $(GITHUB_USERNAME) $(GITHUB_PAT)
	mv bld/appimage/game-x86_64.AppImage $@

bin/$(TITLE)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv bin/$(TITLE)-macos.zip $@

bin/$(TITLE)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv bin/$(TITLE)-win32.zip $@

bin/$(TITLE)-$(VERSION)-web.zip: $(LOVEFILE)
	bld/love-js/love-js.sh bin/$(TITLE)-$(VERSION).love $(TITLE) -v=$(VERSION) -a=$(AUTHOR) -o=bin

linux: bin/$(TITLE)-$(VERSION)-x86_64.AppImage
mac: bin/$(TITLE)-$(VERSION)-macos.zip
windows: bin/$(TITLE)-$(VERSION)-win.zip
web: bin/$(TITLE)-$(VERSION)-web.zip


runweb: $(LOVEFILE)
	bld/love-js/love-js.sh $(LOVEFILE) $(TITLE) -v=$(VERSION) -a=$(AUTHOR) -o=bin -r -n
# If you release on itch.io, you should install butler:
# https://itch.io/docs/butler/installing.html

uploadlinux: bin/$(TITLE)-$(VERSION)-x86_64.AppImage
	butler push $^ $(ITCH_ACCOUNT)/$(TITLE):linux --userversion $(VERSION)
uploadmac: bin/$(TITLE)-$(VERSION)-macos.zip
	butler push $^ $(ITCH_ACCOUNT)/$(TITLE):mac --userversion $(VERSION)
uploadwindows: bin/$(TITLE)-$(VERSION)-win.zip
	butler push $^ $(ITCH_ACCOUNT)/$(TITLE):windows --userversion $(VERSION)
uploadweb: bin/$(TITLE)-$(VERSION)-web.zip
	butler push $^ $(ITCH_ACCOUNT)/$(TITLE):web --userversion $(VERSION)

upload: uploadlinux uploadmac uploadwindows

release: linux mac windows upload cleansrc
