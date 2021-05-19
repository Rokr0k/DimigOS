C_SOURCES = $(wildcard kernel/*.c drivers/*.c cpu/*.c libc/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h cpu/*.h libc/*.c)
OBJ = $(C_SOURCES:.c=.o cpu/interrupt.o)

CC = /home/rok/opt/cross/bin/i386-elf-gcc
GDB = /home/rok/opt/cross/bin/i386-elf-gdb
LD = /home/rok/opt/cross/bin/i386-elf-ld
CFLAGS = -g -ffreestanding -Wall -Wextra -fno-exceptions -m32

os-image.bin: boot/boot_sect.bin kernel.bin
	cat $^ > $@

kernel.bin: boot/kernel_entry.o ${OBJ}
	${LD} -o $@ -Ttext 0x1000 $^ --oformat binary

kernel.elf: boot/kernel_entry.o ${OBJ}
	${LD} -o $@ -Ttext 0x1000 $^

run: os-image.bin
	qemu-system-i386 -fda os-image.bin

debug: os-image.bin kernel.elf
	qemu-system-i386 -s -fda $< &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file $>"

%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -ffreestanding -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	${RM} -rf *.bin *.dis *.o os-image.bin  *.elf
	${RM} -rf kernel/*.o boot/*.bin drivers/*.o boot/*.o cpu/*.o libc/*.o
