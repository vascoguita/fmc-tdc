CFLAGS = -I. -I../lib -I../kernel -Wall -ggdb3
TESTS = fmctdc-list fmctdc-term fmctdc-read fmctdc-acquisition
COMMON_SRCS = test-common.c
LDFLAGS = -L../lib -lfmctdc

all: $(TESTS)

%: %.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) $*.c $(COMMON_SRCS) $(LDFLAGS) -o $@


clean:
	rm -f $(TESTS) test-common.o