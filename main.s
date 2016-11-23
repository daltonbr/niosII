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

.include "constants.s"

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

    # Set the TO flag on the timer back to 0
    ldbio       r15, 0(r17)
    andi        r15, r15, 0b11111110
    stbio       r15, 0(r17)

    # To check which command triggered this timer interrupt, we use the last typed command
    # For now, we just check the first byte:
    #   If it is zero -> blinking mechanism of red led
    #   if it is something else -> rotation of phrase

    movia       r21, LAST_TYPED_COMMAND
    ldb         r10, 0(r21)
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, BLINK_TIMER_INTERRUPT

    # TODO: rotate the phrase on the 7-segment display

BLINK_TIMER_INTERRUPT:
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

    # Move the pointer back, in order to get the next command
    movia       r19, COMMAND_BASE_ADDRESS

    # Save the last typed command for future use, if needed
    movia       r10, LAST_TYPED_COMMAND
    ldw         r11, 0(r19)
    stw         r11, 0(r10)

    br          RETURN_FROM_INTERRUPT

RETURN_FROM_INTERRUPT:
    subi        ea, ea, 4                   # external interrupt must decrement ea, so that the 
    eret                                    # interrupted instruction will be run after eret

# .org GREETING_PHRASE_ADDRESS "Hi 2016"
# .org COMMAND_BASE_ADDRESS
    
.global _start
_start:

    movia       sp, 0x100000
    mov         fp, sp

    # These registers will always contain these values.
    # If some procedure needs to use them, they must save it.
    movia       r16, UART_BASE_ADDRESS
    movia       r17, TIMER_BASE_ADDRESS
    movia       r18, RED_LEDS_STATUS_ADDRESS
    movia       r19, COMMAND_BASE_ADDRESS
    movia       r20, RED_LED_BASE_ADDRESS

    stw         r0, 0(r18)                  # Reset the red leds status address

    # enable Nios II processor interrupts
    movi        r7, 0b100000011             # set interrupt mask bits for #0 (Interval timer),
    wrctl       ienable, r7                 # #1 (Pushbutton switch parallel port), and #8 (JTAG port)
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