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

    movia       r9, TIMER_BASE_ADDRESS
    ldbio       r15, 0(r9)
    andi        r15, r15, 0b11111110
    stbio       r15, 0(r9)

    movia       r13, RED_LEDS_STATUS_ADDRESS         # Get buffer of blinkable leds
    movia       r8, RED_LED_BASE_ADDRESS

    # TODO: Toggle the needed bits in the RED_LED_BASE_ADDRESS
    ldwio       r10, 0(r8)
    ldw         r11, 0(r13)
    beq         r10, r0, LIGHT_ALL_NEEDED_LEDS       # If its zero, there are no leds lighted on

    stwio       r0, 0(r8)                            # tunr off all the freaking lights
    br RETURN_FROM_INTERRUPT                         

LIGHT_ALL_NEEDED_LEDS:
    or          r10, r10, r11                        # Just light the needed lights
    stwio       r10, 0(r8)                           # Save it back to red leds address
    br RETURN_FROM_INTERRUPT

# Reading the character
UART_INTERRUPT:
    ldbio       r10, 0(r8)                           # r10 = DATA (1 byte)
    stb         r10, 0(r15)                          # store the read character into memory
    addi        r15, r15, 1                          # Increment the pointer for the command
    addi        r11, r0, ENTER_ASCII_VALUE           # r11 is a temp register
    beq         r10, r11, VALIDATE_COMMAND           # Checks for <ENTER>
    br RETURN_FROM_INTERRUPT

VALIDATE_COMMAND:
    movia       r15, COMMAND_BASE_ADDRESS         # reset the command pointer to the base address
    ldb         r10, 0(r15)                       # Load the first character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, ZERO_PREFIX_COMMAND      # Check for 0
    addi        r11, r0, 1
    beq         r10, r11, ONE_PREFIX_COMMAND      # Check for 1
    addi        r11, r0, 2
    beq         r10, r11, TWO_PREFIX_COMMAND      # CHeck for 2
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br RETURN_FROM_INTERRUPT

ZERO_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, ZERO_ZERO_COMMAND        # Check for 0
    addi        r11, r0, 1
    beq         r10, r11, ZERO_ONE_COMMAND        # Check for 1
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br RETURN_FROM_INTERRUPT

ONE_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, ONE_ZERO_COMMAND         # Check for 0
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br RETURN_FROM_INTERRUPT    

TWO_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, TWO_ZERO_COMMAND         # Check for 0
    addi        r11, r0, 1
    beq         r10, r11, TWO_ONE_COMMAND         # Check for 1
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br RETURN_FROM_INTERRUPT

ZERO_ZERO_COMMAND:
    ldb         r10, 0(r15)
    addi        r15, r15, 1
    subi        r10, r10, ZERO_ASCII_VALUE
    muli        r11, r10, 10

    ldb         r10, 0(r15)
    subi        r10, r10, ZERO_ASCII_VALUE
    add         r11, r11, r10

    # TODO: check if value is valid (00~17)

    addi        r12, r0, 0b1                    # r12 is a temp register
    sll         r11, r12, r11                   # Now, r11 holds the correct bit set
    br BLINK_RED_LEDS

ZERO_ONE_COMMAND:
    ldb         r10, 0(r15)
    addi        r15, r15, 1
    subi        r10, r10, ZERO_ASCII_VALUE
    muli        r11, r10, 10

    ldb         r10, 0(r15)
    subi        r10, r10, ZERO_ASCII_VALUE
    add         r11, r11, r10                   # Now, r11 holds the shift we have to make to set the right bit on the red leds

    # TODO: cbeck if value is valid (00~17)

    addi        r12, r0, 0b1                    # r12 is a temp register
    sll         r11, r12, r11                   # Now, r11 holds the correct bit set
    br CANCEL_BLINK_RED_LEDS

ONE_ZERO_COMMAND:
    # TODO
    br RETURN_FROM_INTERRUPT

TWO_ZERO_COMMAND:
    # TODO
    br RETURN_FROM_INTERRUPT

TWO_ONE_COMMAND:
    # TODO
    br RETURN_FROM_INTERRUPT

BLINK_RED_LEDS:
    movia       r8, RED_LED_BASE_ADDRESS
    movia       r9, RED_LEDS_STATUS_ADDRESS

    ldw         r10, 0(r9)                     # r10 = current value in the status red leds memory
    or          r10, r11, r10                  # the user input need to be ORed with the current status value
    stw         r10, 0(r9)                     # Set the red leds status

    # set the interval timer period for the red leds
    movia       r9, TIMER_BASE_ADDRESS
    movia       r12, RED_LED_TIMER_INTERVAL    # 1/(50 MHz) × (0x17D7840) = 500 msec
    sthio       r12, 8(r9)                     # store the low halfword of counter (low)...
    srli        r12, r12, 16                   # move the high halfword to the low part
    sthio       r12, 0xC(r9)                   # ...and then store it in the the counter (high)

    # start interval timer, enable its interrupts and set it to reload when reach 0
    movi        r12, 0b0111                    # START = 1, CONT = 1, ITO = 1
    sthio       r12, 4(r9)

    br RETURN_FROM_INTERRUPT

CANCEL_BLINK_RED_LEDS:
    movia       r8, RED_LED_BASE_ADDRESS
    movia       r9, RED_LEDS_STATUS_ADDRESS

    # Reset the bit on the status buffer
    ldw         r11, 0(r9)                     # Load current status buffer
    xori        r12, r10, 0b11111111           # Get the complement of user input
    and         r12, r12, r11                  # We AND here to reset the wanted bit on the status buffer
    stw         r12, 0(r9)                     # Store it into memory again

    # TODO: If there are no bits left to light, stop the timer

RETURN_FROM_INTERRUPT:
    subi        ea, ea, 4                   # external interrupt must decrement ea, so that the 
    eret                                    # interrupted instruction will be run after eret

# .org GREETING_PHRASE_ADDRESS "Hi 2016"
# .org COMMAND_BASE_ADDRESS
    
.global _start
_start:

    movia       r8, UART_BASE_ADDRESS
    movia       r9, TIMER_BASE_ADDRESS
    movia       r10, RED_LEDS_STATUS_ADDRESS
    movia       r15, COMMAND_BASE_ADDRESS

    stw         r0, 0(r10)                  # Reset the red leds status address

    # enable Nios II processor interrupts
    movi        r7, 0b100000001             # set interrupt mask bits for
    wrctl       ienable, r7                 # and #8 (JTAG port)
    movi        r7, 1
    wrctl       status, r7                  # turn on Nios II interrupt processing

    # TODO: print the prompt message

    # enable JTAG uART interrupt for reading (RE)

    ldbio       r12, 4(r8)
    ori         r12, r12, 0b00000001
    sthio       r12, 4(r8)

    IDLE:
        br IDLE
    
.end