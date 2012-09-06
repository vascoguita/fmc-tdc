all:
	$(MAKE) -C drivers
	$(MAKE) -C lib
	$(MAKE) -C test

.PHONY: all clean

clean:
	$(MAKE) clean -C drivers
	$(MAKE) clean -C lib
	$(MAKE) clean -C test
