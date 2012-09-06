LIB = libtdc.a
LOBJ := libtdc.o

CFLAGS = -Wall -ggdb -O2 -I..
LDFLAGS = -L. -ltdc

modules all: lib test

lib: $(LIB)

%: %.c $(LIB)
	$(CC) $(CFLAGS) $*.c $(LDFLAGS) -o $@

$(LIB): $(LOBJ)
	ar r $@ $^

test: test.o

clean:
	rm -f $(LIB) *.o *~ test
