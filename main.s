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
    andi     r14, r13, 0b10                         # mask for Pushbutton parallel port
    bne      r14, r0, PUSHBUTTON_INTERRUPT

    # TODO: check for anything else ? - maybe not an external interruption?

    br      RETURN_FROM_INTERRUPT

PUSHBUTTON_INTERRUPT:

    movia       r9, PUSHBUTTON_BASE_ADDRESS
    ldbio       r10, 0xc(r9)
    
    # Reset edge capture bit
    stbio       r0, 0xc(r9)

    andi        r11, r10, 0b10
    beq         r11, r0, KEY2_PRESS

    # KEY1 was pressed
    movia       r9, ROTATION_DIRECTION_ADDRESS
    ldb         r11, 0(r9)
    beq         r11, r0, CHANGE_ROTATION_TO_LEFT

    # Change rotation to right
    stb         r0, 0(r9)

    br          RETURN_FROM_INTERRUPT

CHANGE_ROTATION_TO_LEFT:

    # Change rotation to right
    addi        r11, r0, 0b1
    stb         r11, 0(r9)

    br          RETURN_FROM_INTERRUPT

KEY2_PRESS:

    # If the ROTATION_STATUS_ADDRESS is zero, we must pause the rotation
    # if it is something other than zero, we must resume.

    movia       r9, ROTATION_STATUS_ADDRESS
    movia       r11, TIMER_BASE_ADDRESS
    ldb         r10, 0(r9)

    beq         r10, r0, PAUSE_ROTATION

    movi        r12, 0b0111                    # STOP = 0, START = 1, CONT = 1, ITO = 1
    sthio       r12, 4(r11)

    # Reset rotation status as playing
    stb         r0, 0(r9)

    br          RETURN_FROM_INTERRUPT

PAUSE_ROTATION:

    # Stop timer
    movi        r12, 0b1011                    # STOP = 1, START = 0, CONT = 1, ITO = 1
    sthio       r12, 4(r11)

    # Set rotation status as paused
    addi        r14, r0, 0b1
    stb         r14, 0(r9)

    br          RETURN_FROM_INTERRUPT

TIMER_INTERRUPT:

    # Set the TO flag on the timer back to 0
    ldbio       r15, 0(r17)
    andi        r15, r15, 0b11111110
    stbio       r15, 0(r17)

    # To check which command triggered this timer interrupt, we use the last typed command
    # For now, we just check the first byte:
    #   If it is zero -> blinking mechanism of red led
    #   if it is something else -> rotation of phrase

    # TODO: we need another way to check which command should run.
    # The way it is now, when a worng command is typed, or a 
    # stop command (21), the timer becomes unstable

    movia       r21, LAST_TYPED_COMMAND
    ldb         r10, 0(r21)
    subi        r10, r10, ZERO_ASCII_VALUE           # we want the numeric value
    beq         r10, r0, BLINK_TIMER_INTERRUPT       # If it is zero, it is the blinking mechanism
    call        ROTATE_PHRASE                        # else, it is the rotation mechanism
    br          RETURN_FROM_INTERRUPT

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
    stbio       r10, 0(r16)                          # echo the typed character
    stb         r10, 0(r19)                          # store the read character into memory
    addi        r19, r19, 1                          # Increment the pointer for the command
    addi        r11, r0, ENTER_ASCII_VALUE           # r11 is a temp register
    bne         r10, r11, RETURN_FROM_INTERRUPT      # Checks for <ENTER>
    call        VALIDATE_COMMAND

    # Move the pointer back, in order to get the next command
    movia       r19, COMMAND_BASE_ADDRESS

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