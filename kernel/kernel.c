#include "../cpu/isr.h"
#include "../drivers/screen.h"
#include "kernel.h"
#include "../libc/string.h"
#include "../libc/mem.h"

void kernel_main() {
    isr_install();
    irq_install();

    clear_screen();
    
    kprint("Type \"jatoe\" to halt the CPU\n$ ");
}

void user_input(char *input) {
    if(strcmp(input, "jatoe") == 0) {
        kprint("Stopping the CPU. Bye!\n");
        asm volatile("hlt");
    }
    kprint("You said: ");
    kprint(input);
    kprint("\n$ ");
}
