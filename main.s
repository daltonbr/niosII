/************************************************************************
 * Final Project for the course of Microprocessors II                   *
 * (not tested)                                                                     *
 * 2016/10/0614                                                         *
 * Professor: Joao Paulo L de Carvalho                                  *
 * Authors:                                                             *
 * Dalton Lima @daltonbr                                                *
 * Giovanna Cazelato @giovannaC                                         *
 * Lucas Pinheiro @lucaspin                                             *
 ***********************************************************************/

/******************************************************************************************
 * | Command | Action                                                                     | 
 * |---------|----------------------------------------------------------------------------|
 * |  00 xx  | Blink the xx-nth – red led in intervals of 500 ms                          |
 * |  01 xx  | Cancel the blinking of the xx-nth red led                                  |      
 * |  10     | Read the content of first 8 bits of the switch keys (SW7-0) and calculate  |
 * |         | the respective triangular number. The result must be show in the 7-segment | 
 * |         | display in decimal                                                         | 
 * |  20	 | Show the phrase “Hi 2016” in the 7-segment display and rotate them to      |
 * |         | the right in intervals of 200ms. If KEY1 was pressed them the direction of |
 * |         | of the rotation must be inverted. If KEY2 was pressed, them the rotation   |
 * |         | must be paused. Pressing KEY2 again must resume the rotation               |
 * |  21	 | Stop rotation of the phrase                                                |
*******************************************************************************************/
 
 # Base Addresses
.equ RED_LED_BASE_ADDRESS,       0x10000000          # 17 - 0 less significant bits
.equ GREEN_LED_BASE_ADDRESS,     0x10000010          #  8 - 0 less significant bits
.equ HEX_DISPLAY30_BASE_ADDRESS, 0x10000020
.equ HEX_DISPLAY74_BASE_ADDRESS, 0x10000020
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

    .text                                                # executable code follows
.org        0x20
.global     INTERRUPTION_HANDLER

# checking ipending (ctl4) to see which interruption occurred and branching accordingly
INTERRUPTION_HANDLER:  
    rdctl    r13, ipending
    andi     r14, r13, 0b1                          # mask for Timer interruption
    bne      r14, r0, TIMER_INTERRUPT
    andi     r14, r13, 0b100000000                  # mask for JTAG UART interruption
    bne      r14, r0, UART_INTERRUPT
    # check for anything else ? - maybe not an external interruption? 

TIMER_INTERRUPT:

    # Here, we are assuming that the only timer interrupts are regarding the blinking of leds

    # Set the TO flag on the timer back to 0
    ldbio       r15, 0(r17)
    andi        r15, r15, 0b11111110
    stbio       r15, 0(r17)

    # Check if there is some red led on
    ldwio       r10, 0(r20)
    ldw         r11, 0(r18)
    beq         r10, r0, LIGHT_ALL_NEEDED_LEDS       # If its zero, there are no leds lighted on

    stwio       r0, 0(r20)                           # turm off all the freaking lights
    br RETURN_FROM_INTERRUPT                         

LIGHT_ALL_NEEDED_LEDS:
    or          r10, r10, r11                        # Just light the needed lights
    stwio       r10, 0(r20)                          # Save it back to red leds address
    br RETURN_FROM_INTERRUPT

# Reading the character
UART_INTERRUPT:
    ldbio       r10, 0(r16)                          # r10 = DATA (1 byte)
    stb         r10, 0(r19)                          # store the read character into memory
    addi        r19, r19, 1                          # Increment the pointer for the command
    addi        r11, r0, ENTER_ASCII_VALUE           # r11 is a temp register
    bne         r10, r11, RETURN_FROM_INTERRUPT      # Checks for <ENTER>
    call        VALIDATE_COMMAND
    br          RETURN_FROM_INTERRUPT

RETURN_FROM_INTERRUPT:
    subi        ea, ea, 4                   # external interrupt must decrement ea, so that the 
    eret                                    # interrupted instruction will be run after eret

# .org GREETING_PHRASE_ADDRESS "Hi 2016"
# .org COMMAND_BASE_ADDRESS
    
.global _start
_start:

    # These registers will always contain these values.
    # If some procedure needs to use them, they must save it.
    movia       r16, UART_BASE_ADDRESS
    movia       r17, TIMER_BASE_ADDRESS
    movia       r18, RED_LEDS_STATUS_ADDRESS
    movia       r19, COMMAND_BASE_ADDRESS
    movia       r20, RED_LED_BASE_ADDRESS

    stw         r0, 0(r18)                  # Reset the red leds status address

    # enable Nios II processor interrupts
    movi        r7, 0b100000001             # set interrupt mask bits for
    wrctl       ienable, r7                 # and #8 (JTAG port)
    movi        r7, 1
    wrctl       status, r7                  # turn on Nios II interrupt processing

    # TODO: print the prompt message

    # enable JTAG uART interrupt for reading (RE)

    ldbio       r12, 4(r16)
    ori         r12, r12, 0b00000001
    sthio       r12, 4(r16)

    IDLE:
        br IDLE
    
.end