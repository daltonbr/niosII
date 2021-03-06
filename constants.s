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
.equ LAST_TYPED_COMMAND,         0x0001200c
.equ ROTATION_DIRECTION_ADDRESS, 0x00012010
.equ ROTATION_STATUS_ADDRESS,    0x00012014

# Masks
.equ WSPACE_UART_mask,           0xFF00              # only high halfword (imm16)
.equ RAVAIL_UART_mask,           0xFF00              # only high halfword (imm16)
.equ DATA_UART_mask,             0x00FF
.equ RVALID_UART_mask,           0b1000000000000000  # more visual than 65536 [decimal]  
.equ RIGHTMOST_BYTE_mask,        0x000000FF
.equ LEFTMOST_BYTE_mask,         0xFF000000

# Constants
.equ RED_LED_TIMER_INTERVAL,     0x017D7840          # 1/(50 MHz) × (0x17D7840) = 500ms
.equ ROTATION_TIMER_INTERVAL,    0x00989680          # 1/(50 MHz) x (0x989680) = 200ms
.equ ZERO_ASCII_VALUE,           0x30
.equ ENTER_ASCII_VALUE,          0xa
.equ GREETING_PHRASE_FIRST,	     0x00763000          # " HI "
.equ GREETING_PHRASE_SECOND,     0x5b3f067d          # "2016"