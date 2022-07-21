CC = cc
LIB = preloadable-usocks.so
SOURCES = usocks.c

$(LIB): $(SOURCES)
	$(CC) $(CFLAGS) -fPIC -ldl -shared -o $(@) $(SOURCES)

all: $(LIB)
clean: ; rm -f $(LIB)
force: clean all
