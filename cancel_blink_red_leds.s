.include "constants.s"

# This procedure is responsible to stop blinking the user selected led.
# In order to do this, we reset the selected bit on the red led status buffer in memory.
# This way, the next time the timer interrupts to light the leds, it will not light the
# selected led.
# 
# Parameters:
# r4 - will hold the bit selected by the user to stop blinking

.global CANCEL_BLINK_RED_LEDS
CANCEL_BLINK_RED_LEDS:

    # Build the stack
    addi        sp, sp, -8
    stw         fp, 0(sp)
    stw         ra, 4(sp)
    addi        fp, sp, 0

    # Reset the bit on the status buffer
    movia       r8, RED_LEDS_STATUS_ADDRESS
    movia       r9, 0xffffffff
    ldw         r11, 0(r8)                     # Load current status buffer

    xor         r12, r4, r9                    # Get the complement of user input
    and         r12, r12, r11                  # We AND here to reset the wanted bit on the status buffer
    stw         r12, 0(r8)                     # Store it into memory again

    # TODO: If there are no bits left to light, stop the timer

    # Tear down the stack and return
    ldw         fp, 0(sp)
    ldw         ra, 4(sp)
    addi        sp, sp, 8
    ret