#include "keyboard.h"
#include "../cpu/ports.h"
#include "../cpu/isr.h"
#include "screen.h"
#include "../libc/string.h"
#include "../libc/function.h"
#include "../kernel/kernel.h"
#include <stdint.h>

#define BACKSPACE 0x0E
#define ENTER 0x1C
#define LSHIFT 0x2A
#define RSHIFT 0x36

static char key_buffer[256];

#define SC_MAX 0x39
#define SC_KEYUP 0x80
const char *sc_name[] = { "ERROR", "Esc", "1", "2", "3", "4", "5", "6", 
    "7", "8", "9", "0", "-", "=", "Backspace", "Tab", "Q", "W", "E", 
    "R", "T", "Y", "U", "I", "O", "P", "[", "]", "Enter", "Lctrl", 
    "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "`", 
    "LShift", "\\", "Z", "X", "C", "V", "B", "N", "M", ",", ".", 
    "/", "RShift", "Keypad *", "LAlt", "Spacebar"};
const char sc_ascii_low[] = { '\0', '\0', '1', '2', '3', '4', '5', '6',     
    '7', '8', '9', '0', '-', '=', '\0', '\0', 'q', 'w', 'e', 'r', 't', 'y', 
    'u', 'i', 'o', 'p', '[', ']', '\0', '\0', 'a', 's', 'd', 'f', 'g', 
    'h', 'j', 'k', 'l', ';', '\'', '`', '\0', '\\', 'z', 'x', 'c', 'v', 
    'b', 'n', 'm', ',', '.', '/', '\0', '\0', '\0', ' '};
const char sc_ascii_up[] = { '\0', '\0', '!', '@', '#', '$', '%', '^',     
    '&', '*', '(', ')', '_', '+', '\0', '\0', 'Q', 'W', 'E', 'R', 'T', 'Y', 
    'U', 'I', 'O', 'P', '{', '}', '\0', '\0', 'A', 'S', 'D', 'F', 'G', 
    'H', 'J', 'K', 'L', ':', '\"', '~', '\0', '|', 'Z', 'X', 'C', 'V', 
    'B', 'N', 'M', '<', '>', '?', '\0', '\0', '\0', ' '};

uint8_t shift_state = 0;
static void keyboard_callback(registers_t *regs) {
    uint8_t scancode = port_byte_in(0x60);
    if(scancode <= SC_MAX) {
        if (scancode == BACKSPACE) {
            if(backspace(key_buffer))
                kprint_backspace();
        } else if (scancode == ENTER) {
            kprint("\n");
            user_input(key_buffer);
            key_buffer[0] = '\0';
        } else if(scancode == LSHIFT || scancode == RSHIFT) {
            shift_state = 1;
        } else if(scancode <= SC_MAX) {
            char letter = shift_state ? sc_ascii_up[(int)scancode] : sc_ascii_low[(int)scancode];
            if(letter) {
                char str[2] = {letter, '\0'};
                append(key_buffer, letter);
                kprint(str);
            }
        }
    } else if(scancode >= SC_KEYUP && scancode <= SC_MAX + SC_KEYUP) {
        if(scancode == LSHIFT + SC_KEYUP || scancode == RSHIFT + SC_KEYUP) {
            shift_state = 0;
        }
    }
    UNUSED(regs);
}

void init_keyboard() {
    register_interrupt_handler(IRQ1, keyboard_callback); 
}
