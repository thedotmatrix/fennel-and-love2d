VERSION=0.1.0
LOVE_VERSION=11.5
NAME=rochambullet
ITCH_ACCOUNT=thedotmatrix
URL=https://github.com/thedotmatrix/fennel-and-love2d
AUTHOR="Dot Matrix"
DESCRIPTION="Minimal setup for trying out Phil Hagelberg's fennel/love game design process."
GITHUB_USERNAME := $(shell grep GITHUB_USERNAME credentials.private | cut -d= -f2)
GITHUB_PAT := $(shell grep GITHUB_PAT credentials.private | cut -d= -f2)
LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl macros/*.fnl monads/*.fnl $(NAME)/*.fnl)

run: ; love .

count: ; cloc *.fnl

clean: ; rm -rf bin/*

LOVEFILE=bin/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(SRC) $(LIBS) assets/$(NAME)
	mkdir -p bin/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL=$(PWD)/bld/love-release.sh # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love $(LOVE_VERSION) --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

bin/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd bld/appimage && \
	./build.sh $(LOVE_VERSION) $(PWD)/$(LOVEFILE) $(GITHUB_USERNAME) $(GITHUB_PAT)
	mv bld/appimage/game-x86_64.AppImage $@

bin/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv bin/$(NAME)-macos.zip $@

bin/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv bin/$(NAME)-win32.zip $@

bin/$(NAME)-$(VERSION)-web.zip: $(LOVEFILE)
	bld/love-js/love-js.sh bin/$(NAME)-$(VERSION).love $(NAME) -v=$(VERSION) -a=$(AUTHOR) -o=bin

linux: bin/$(NAME)-$(VERSION)-x86_64.AppImage
mac: bin/$(NAME)-$(VERSION)-macos.zip
windows: bin/$(NAME)-$(VERSION)-win.zip
web: bin/$(NAME)-$(VERSION)-web.zip


runweb: $(LOVEFILE)
	bld/love-js/love-js.sh $(LOVEFILE) $(NAME) -v=$(VERSION) -a=$(AUTHOR) -o=bin -r -n
# If you release on itch.io, you should install butler:
# https://itch.io/docs/butler/installing.html

uploadlinux: bin/$(NAME)-$(VERSION)-x86_64.AppImage
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):linux --userversion $(VERSION)
uploadmac: bin/$(NAME)-$(VERSION)-macos.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):mac --userversion $(VERSION)
uploadwindows: bin/$(NAME)-$(VERSION)-win.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):windows --userversion $(VERSION)
uploadweb: bin/$(NAME)-$(VERSION)-web.zip
	butler push $^ $(ITCH_ACCOUNT)/$(NAME):web --userversion $(VERSION)

upload: uploadlinux uploadmac uploadwindows

release: linux mac windows upload cleansrc
