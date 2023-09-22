This compiles with the Gnu compiler using "make"

make - builds the executable image .elf
make download copies the image to the MSP430 attched to the TI fdownload and debugger tool (FET)
				using msp430-jtag also found in the gnu compiler mspgcc
				
note: make.exe is not part of the mspgcc installation and has therefore been copied into the source 
tree from a winavr installation