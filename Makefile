#
#
#

SHELL = /bin/sh
SDCCFLAGS = --model-large
ASLINKFLAGS = --code-loc 0x8000 --data-loc 0x30 --stack-after-data --xram-loc 0xD000
MODULES = main.rel csio.rel csioa.rel lcd_disp.rel tcp.rel udp.rel icmp.rel arp.rel ip.rel

%.rel: %.c
	sdcc $(SDCCFLAGS) -c $<

#main.rel: main.c
#	sdcc $(SDCCFLAGS) -c $<

%.rel: %.asm
	asx8051 -los $<

all: microweb.hex

microweb.hex :: $(MODULES)
	sdcc $(SDCCFLAGS) $(ASLINKFLAGS) $(MODULES)
	packihx main.ihx > microweb.hex

clean:
	rm -f tcp.asm udp.asm icmp.asm arp.asm ip.asm csio.asm
	rm -f *.hex *.ihx *.lnk *.lst *.map *.rel *.rst *.sym

