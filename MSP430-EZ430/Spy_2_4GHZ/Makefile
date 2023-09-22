CCPREFIX	= msp430-
CC	= $(CCPREFIX)gcc
CPU	= msp430x2274
CFLAGS	= -g -W -Wall -O2 -mmcu=$(CPU) -MD $(addprefix -D,$(DEFINE))
LDFLAGS	= -g -mmcu=$(CPU)

BASENAME	= spy2_4ghz


# Tell make to also search for source files in ../ (used for common files)
# VPATH	+= ..

OBJS	= main.o hal_spi_radio.o hal_radio.o uart0_polled.o

$(BASENAME).elf	: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	$(CCPREFIX)size $@

clean:
	rm -f $(OBJS:.o=.d) $(OBJS) $(BASENAME).elf

download:
	msp430-jtag --spy-bi-wire -lpt=USBFET -e $(BASENAME).elf

include make.debug
-include $(wildcard *.d)
