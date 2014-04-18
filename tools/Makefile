TESTS = fmc-tdc-list \
	fmc-tdc-term \
	fmc-tdc-read \
	fmc-tdc-acquisition \
	fmc-tdc-temperature \
	fmc-tdc-time

CFLAGS = -I. -I../lib -I../kernel -Wall 

COMMON_SRCS = test-common.c
LDFLAGS = -L../lib -lfmctdc

all: $(TESTS)

%: %.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) $*.c $(COMMON_SRCS) $(LDFLAGS) -o $@


clean:
	rm -f $(TESTS) test-common.o