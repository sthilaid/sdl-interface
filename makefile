PREFIX=.
INCLUDE_PATH=$(PREFIX)/include
SRC_PATH=$(PREFIX)/src
LIB_PATH=$(PREFIX)/lib
EXTERNAL_LIBS=$(PREFIX)/external-libs

PATH_TO_SDL=/usr
SDL_INCLUDE=$(PATH_TO_SDL)/include/SDL
SDL_LIB=$(PATH_TO_SDL)/lib

CCOPTS=-I$(SDL_INCLUDE)
LDOPTS=-L$(SDL_LIB) -lSDL

INCLUDE_FILES=scm-lib_.scm
LIB_FILES=scm-lib.o1 sdl-interface.o1

all: prefix include lib

prefix:
ifneq "$(PREFIX)" "."
	mkdir -p $(PREFIX)
endif

include: $(addprefix $(INCLUDE_PATH)/, $(INCLUDE_FILES))
$(INCLUDE_PATH)/%.scm: $(SRC_PATH)/%.scm
	mkdir -p $(INCLUDE_PATH)
	cp -f $< $@

lib: $(addprefix $(LIB_PATH)/, $(LIB_FILES))
$(LIB_PATH)/%.o1: $(SRC_PATH)/%.scm
	mkdir -p $(LIB_PATH)
	gsc -cc-options "$(CCOPTS)/" -ld-options "$(LDOPTS)" -o $@ $<

$(SRC_PATH)/scm-lib.scm $(SRC_PATH)/scm-lib_.scm: setup-scm-lib
setup-scm-lib:
	mkdir -p $(LIB_PATH)
	mkdir -p $(EXTERNAL_LIBS)
ifeq "$(wildcard $(EXTERNAL_LIBS)/scm-lib)" ""
	cd $(EXTERNAL_LIBS) && git clone git://github.com/sthilaid/scm-lib.git
endif
	cd $(EXTERNAL_LIBS)/scm-lib && git pull
	$(MAKE) -C $(EXTERNAL_LIBS)/scm-lib
	cp $(EXTERNAL_LIBS)/scm-lib/include/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/scm-lib/src/* $(SRC_PATH)/
	cp $(EXTERNAL_LIBS)/scm-lib/lib/* $(LIB_PATH)/

clean:
	rm -rf $(EXTERNAL_LIBS) $(INCLUDE_PATH) $(LIB_PATH)