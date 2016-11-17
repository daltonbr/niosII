 # Base Addresses
.equ RED_LED_BASE_ADDRESS,       0x10000000          # 17 - 0 less significant bits
.equ GREEN_LED_BASE_ADDRESS,     0x10000010          #  8 - 0 less significant bits
.equ HEX_DISPLAY30_BASE_ADDRESS, 0x10000020
.equ HEX_DISPLAY74_BASE_ADDRESS, 0x10000030
.equ SW70_BASE_ADDRESS,          0x10000040
.equ PUSHBUTTON_BASE_ADDRESS,    0x10000050
.equ UART_BASE_ADDRESS,          0x10001000
.equ TIMER_BASE_ADDRESS,         0x10002000
.equ COMMAND_BASE_ADDRESS,       0x00015000
.equ RED_LEDS_STATUS_ADDRESS,    0x00012000
.equ GREETING_PHRASE_ADDRESS,    0x00010000

# Masks
.equ WSPACE_UART_mask,           0xFF00              # only high halfword (imm16)
.equ RAVAIL_UART_mask,           0xFF00              # only high halfword (imm16)
.equ DATA_UART_mask,             0x00FF
.equ RVALID_UART_mask,           0b1000000000000000  # more visual than 65536 [decimal]  

# Constants
.equ RED_LED_TIMER_INTERVAL,     0x017D7840          # 1/(50 MHz) × (0x17D7840) = 500ms
.equ ZERO_ASCII_VALUE,           0x30
.equ ENTER_ASCII_VALUE,          0xa
.equ DISPLAY_TIMER_INTERVAL,     0x989680            # 1/(50 MHz) x (0x989680) = 200ms
