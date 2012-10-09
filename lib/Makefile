ZIO ?= $(HOME)/dependencies/zio

LIB = libtdc.a
LOBJ := libtdc.o

CFLAGS = -Wall -ggdb -I.. -I$(ZIO)/include
LDFLAGS = -L. -ltdc

modules all: lib

lib: $(LIB)

%: %.c $(LIB)
	$(CC) $(CFLAGS) $*.c $(LDFLAGS) -o $@

$(LIB): $(LOBJ)
	ar r $@ $^

clean:
	rm -f $(LIB) *.o *~
