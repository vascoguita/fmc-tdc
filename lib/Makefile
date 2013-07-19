# This is not a kbuild Makefile. It is a plain Makefile so it can be copied

LIB = libfmctdc.a
LOBJ := fmctdc-lib.o

CFLAGS = -Wall -ggdb -O2 -I../kernel -I../zio/include
LDFLAGS = -L. -lfmctdc

TEST_OBJS = fmctdc-test.o


modules all: lib testprog

lib: $(LIB)

testprog: $(TEST_OBJS)
	$(CC) -o fmctdc-test $(TEST_OBJS) $(LIB)
	ln -sf fmctdc-test fmctdc-identify
	ln -sf fmctdc-test fmctdc-read
	ln -sf fmctdc-test fmctdc-termination
	ln -sf fmctdc-test fmctdc-time
	ln -sf fmctdc-test fmctdc-list

%: %.c $(LIB)
	$(CC) $(CFLAGS) $*.c $(LDFLAGS) -o $@

$(LIB): $(LOBJ)
	ar r $@ $^

clean:
	rm -f $(LIB) .depend *.o *~

.depend: Makefile $(wildcard *.c *.h ../*.h)
	$(CC) $(CFLAGS) -M $(LOBJ:.o=.c) -o $@

install modules_install:

-include .depend

