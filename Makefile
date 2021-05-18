all: run

run: dimigos.bin
	qemu-system-x86_64 $<

dimigos.bin: bootload.asm
	nasm -f bin $< -o $@

clean:
	$(RM) *.bin