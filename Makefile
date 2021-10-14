# Edit to fit needs
CC       = clang
LIB_H    =
LIB_C    =
DEFINES  =
SANS     = undefined,address,leak
WARNS    = all pedantic extra
OPTIMIZE = -O3
OUTPUT   =
ENV      = ASAN_OPTIONS=fast_unwind_on_malloc=0 LSAN_OPTIONS=report_objects=1
ARGS     =

# Shouldn't really be touched
HDRDIR  = include
HDREXT  = .h
SRCDIR  = src
SRCEXT  = .c
OBJDIR  = objects
OBJEXT  = .o
TSTDIR  = test
DEPS    = $(basename $(shell ls $(HDRDIR)))
INPUTS  = $(basename $(shell ls $(SRCDIR)))
HEADERS = $(addprefix $(HDRDIR)/, $(addsuffix $(HDREXT), $(DEPS)))
SOURCES = $(addprefix $(SRCDIR)/, $(addsuffix $(SRCEXT), $(INPUTS)))
OBJECTS = $(addprefix $(OBJDIR)/, $(addsuffix $(OBJEXT), $(INPUTS)))
CFLAGS  = $(addprefix -D, $(DEFINES)) -I$(HDRDIR) -c -o
LDFLAGS = -o

# Calling run without building will build
# without optimizations and debug flags
.PHONY: debug
.PHONY: release
.PHONY: build
.PHONY: run
.PHONY: clean

# Build with warnings, sanitizers and DEBUG flags
debug: DEFINES := DEBUG $(DEFINES)
debug: CFLAGS  := $(addprefix -W, $(WARNS)) $(CFLAGS)
debug: LDFLAGS := -fsanitize=$(SANS) $(LDFLAGS)
debug: build

# Build with optimizers and NDEBUG flags
release: DEFINES := NDEBUG $(DEFINES)
release: CFLAGS  := $(OPTIMIZE) $(CFLAGS)
release: LDFLAGS := $(LDFLAGS)
release: build

# Actually build the executable
# Should not be manually called
build: | $(HDRDIR) $(SRCDIR) $(OBJDIR) $(TSTDIR) $(OUTPUT)

# Run executable with args
run: $(OUTPUT)
	$(ENV) ./$(OUTPUT) $(ARGS)

# Clean up generated executable and object files
clean:
	rm $(OBJECTS) $(OUTPUT)

# Link libraries and build executables
$(OUTPUT): $(OBJECTS)
	$(CC) $(LDFLAGS) $@ $^ $(addprefix -l, $(LIB_C))

# Link header-only libraries and build object files
$(OBJDIR)/%$(OBJEXT): $(SRCDIR)/%$(SRCEXT)
	$(CC) $(CFLAGS)  $@ $< $(addprefix -l, $(LIB_H))

# Generate necessary directories
$(HDRDIR) $(SRCDIR) $(OBJDIR) $(TSTDIR): % :
	mkdir $@
