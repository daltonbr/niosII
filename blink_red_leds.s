.include "constants.s"

# This procedure is responsible to set the selected led to be blinkable
# In order to do this, we set the selected bit on the red led status buffer in memory.
# This way, the next time the timer interrupts to light the leds, it will get new
# selected one as well.
# 
# Parameters:
# r4 - will hold the bit selected by the user to blink

.global BLINK_RED_LEDS
BLINK_RED_LEDS:

    # Build the stack
    addi        sp, sp, -8
    stw         fp, 0(sp)
    stw         ra, 4(sp)
    addi        fp, sp, 0

    movia       r8, RED_LED_BASE_ADDRESS
    movia       r9, RED_LEDS_STATUS_ADDRESS

    ldw         r10, 0(r9)                     # r10 = current value in the status red leds memory
    or          r10, r4, r10                   # the user input need to be ORed with the current status value
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

    # Tear down the stack and return
    ldw         fp, 0(sp)
    ldw         ra, 4(sp)
    addi        sp, sp, 8
    ret