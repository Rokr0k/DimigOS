#include "../cpu/isr.h"
#include "../drivers/screen.h"
#include "kernel.h"
#include "../libc/string.h"
#include "../libc/mem.h"

void kernel_main() {
	isr_install();
	irq_install();
	
	kprint("Type EXIT to halt the CPU or PAGE to request a kmalloc()\n$ ");
}

void user_input(char *input) {
	if(strcmp(input, "EXIT") == 0) {
		kprint("Stopping the CPU. Bye!\n");
		asm volatile("hlt");
	} else if(strcmp(input, "PAGE") == 0) {
		uint32_t phys_addr;
		uint32_t page = kmalloc(1000, 1, &phys_addr);
		char page_str[16] = "";
		hex_to_ascii(page, page_str);
		char phys_str[16] = "";
		hex_to_ascii(phys_addr, phys_str);
		kprint("Page: ");
		kprint(page_str);
		kprint(", physical address: ");
		kprint(phys_str);
		kprint("\n");
	}
	kprint("You said: ");
	kprint(input);
	kprint("\n$ ");
}