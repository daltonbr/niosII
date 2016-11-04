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
 
 /* base addresses */
.equ RED_LED_BASE_ADDRESS,      0x10000000          # 17 - 0 less significant bits
.equ GREEN_LED_BASE_ADDRESS,    0x10000010          #  8 - 0 less significant bits
.equ HEX_DISPLAY30_BASE_ADDRESS 0x10000020
.equ HEX_DISPLAY74_BASE_ADDRESS 0x10000020
.equ SW70_BASE_ADDRESS,         0x10000040
.equ PUSHBUTTON_BASE_ADDRESS,   0x10000050
.equ UART_BASE_ADDRESS,         0x10001000
.equ TIMER_BASE_ADDRESS,        0x10002000

/* masks */
.equ WSPACE_UART_mask,          0xFF00              # only high halfword (imm16)
.equ RAVAIL_UART_mask,          0xFF00              # only high halfword (imm16)
.equ DATA_UART_mask,            0x00FF
.equ RVALID_UART_mask,          0b1000000000000000  # more visual than 65536 [decimal]  

/* constants */
.equ TIMER_INTERVAL,            0x017D7840          # 1/(50 MHz) × (0x17D7840) = 500 msec
.equ GREETING_PHRASE,           "Hi 2016"

/* debugging purpose */
.equ INPUT_RED_LEDS,            0b10                # turn on the led #1
    
    .text                                           # executable code follows

    .org 0x20
    .global     INTERRUPTION_HANDLER
/* checking ipending (ctl4) to see which interruption occurred
 * and branching accordingly */
INTERRUPTION_HANDLER:  
    rdctl    r13, ipending
    andi     r14, r13, 0b100000000                  # mask for Timer interruption
    bne      r14, r0, TIMER_INTERRUPT    
    andi     r14, r13, 0b1                          # mask for JTAG UART interruption
    bne      r14, r0, UART_INTERRUPT
    # check for anything else ? - maybe not an external interruption? 

TIMER_INTERRUPT:
/* Let's blink the red leds */
    stwio    r10, 0(r8)                             # Writing the DATA (note: writing into this register
                                                    # has no effect on received data) 
    subi     ea, ea, 4                              # external interrupt must decrement ea, so that the 
    eret                                            # interrupted instruction will be run after eret
    
    .global _start
_start:

    /* we need to take input from the user and assess the command that was entered */

/* blinkinkg the leds */
/* turn on the requested led to blink (input from user) */
    movia    r8, RED_LED_BASE_ADDRESS
    ldwio    r10, 0(r8)                             # r10 = current value in RLED Data Register
    movia    r9, INPUT_RED_LEDS                     # r9 = # led to be turned on (from user input) - hardcoded for testing purpose
    or       r10, r10, r9                           # the user input need to be ORed with the current value in RLEDs                                                    
    stwio    r10, 0(r8)                             # set the RLED Data Register

    movia       r8, UART_BASE_ADDRESS
    movia       r9, TIMER_BASE_ADDRESS

/* set the interval timer period for scrolling the HEX displays */
    movia       r12, TIMER_INTERVAL         # 1/(50 MHz) × (0x17D7840) = 500 msec
    sthio       r12, 8(r9)                  # store the low halfword of counter (low)...
    srli        r12, r12, 16                # move the high halfword to the low part
    sthio       r12, 0xC(r9)                # ...and then store it in the the counter (high)

/* start interval timer, enable its interrupts and set it to reload when reach 0 */
    movi        r13, 0b0111                 # START = 1, CONT = 1, ITO = 1
    sthio       r13, 4(r9)

/* enable Nios II processor interrupts */
    movi        r7, 0b100000001             # set interrupt mask bits for IRQ #0 (interval
    wrctl       ienable, r7                 # timer) and #8 (JTAG port) 
    movi        r7, 1
    wrctl       status, r7                  # turn on Nios II interrupt processing
    


END: 
    br END

.end