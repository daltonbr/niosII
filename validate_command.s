.include "constants.s"

.global VALIDATE_COMMAND
VALIDATE_COMMAND:
    addi        sp, sp, -8                        # Build the stack
    stw         fp, 0(sp)
    stw         ra, 4(sp)
    addi        fp, sp, 0

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
    br          END_VALIDATE_COMMAND

ZERO_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, ZERO_ZERO_COMMAND        # Check for 0
    addi        r11, r0, 1
    beq         r10, r11, ZERO_ONE_COMMAND        # Check for 1
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br          END_VALIDATE_COMMAND

ONE_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, ONE_ZERO_COMMAND         # Check for 0
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br          END_VALIDATE_COMMAND    

TWO_PREFIX_COMMAND:
    ldb         r10, 0(r15)                       # Load the second character typed
    addi        r15, r15, 1                       # Increment the pointer
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    beq         r10, r0, TWO_ZERO_COMMAND         # Check for 0
    addi        r11, r0, 1
    beq         r10, r11, TWO_ONE_COMMAND         # Check for 1
    movia       r15, COMMAND_BASE_ADDRESS         # Invalid command
    br          END_VALIDATE_COMMAND

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
    sll         r4, r12, r11                    # Place the correct bit set on r4 to pass to the procedure
    call        BLINK_RED_LEDS
    br          END_VALIDATE_COMMAND

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
    sll         r4, r12, r11                    # Now, r4 holds the correct bit set
    call        CANCEL_BLINK_RED_LEDS
    br          END_VALIDATE_COMMAND

ONE_ZERO_COMMAND:

    # get bits from switch keys
    movia       r8, SW70_BASE_ADDRESS
    ldb         r4, 0(r8)
    andi        r4, r4, 0x000000ff              # Reset all other bytes

    # calculate triangular number
    call        TRIANGULAR

    # display in the 7-segment display
    add         r4, r0, r2
    call        TWO_BYTES_BIN_TO_5BYTES_HEXDISPLAY

    movia       r9, HEX_DISPLAY30_BASE_ADDRESS
    movia       r10, HEX_DISPLAY74_BASE_ADDRESS
    stwio       r2, 0(r9)
    stwio       r3, 0(r10)

    br          END_VALIDATE_COMMAND

TWO_ZERO_COMMAND:
    # Put the phrase in the 7-segment display
    movia       r9, GREETING_PHRASE_FIRST
    movia       r10, HEX_DISPLAY74_BASE_ADDRESS
    stwio       r9, 0(r10)

    movia       r9, GREETING_PHRASE_SECOND
    movia       r10, HEX_DISPLAY30_BASE_ADDRESS
    stwio       r9, 0(r10)

    # Set the direction of the rotation, initially to the right.
    # Zero means right, anything else means left
    movia       r9, ROTATION_DIRECTION_ADDRESS
    stb         r0, 0(r9)

    # set the interval timer period for the rotation
    movia       r9, TIMER_BASE_ADDRESS
    movia       r12, ROTATION_TIMER_INTERVAL   # 1/(50 MHz) × (0x17D7840) = 500 msec
    sthio       r12, 8(r9)                     # store the low halfword of counter (low)...
    srli        r12, r12, 16                   # move the high halfword to the low part
    sthio       r12, 0xC(r9)                   # ...and then store it in the the counter (high)

    # start interval timer, enable its interrupts and set it to reload when reach 0
    movi        r12, 0b0111                    # START = 1, CONT = 1, ITO = 1
    sthio       r12, 4(r9)

    movia       r9, ROTATION_STATUS_ADDRESS
    stb         r0, 0(r9)

    # Enable interrupts for KEY1 and KEY2
    movia       r9, PUSHBUTTON_BASE_ADDRESS
    addi        r12, r0, 0b110
    stbio       r12, 8(r9)

    br          END_VALIDATE_COMMAND

TWO_ONE_COMMAND:

    movia       r9, LAST_TYPED_COMMAND
    ldb         r10, 0(r9)
    subi        r10, r10, ZERO_ASCII_VALUE        # we want the numeric value
    addi        r13, r0, 2
    bne         r10, r13, STOP_COMMAND_END

    # Just stop timer if last command was 2-indexed
    movia       r11, TIMER_BASE_ADDRESS
    movi        r12, 0b1011                    # STOP = 1, START = 0, CONT = 1, ITO = 1
    sthio       r12, 4(r11)

STOP_COMMAND_END:

    # Disable interrupts for KEY1 and KEY2
    movia       r9, PUSHBUTTON_BASE_ADDRESS
    stbio       r0, 8(r9)

    # Remove message from leds
    movia       r10, HEX_DISPLAY74_BASE_ADDRESS
    stwio       r0, 0(r10)
    movia       r10, HEX_DISPLAY30_BASE_ADDRESS
    stwio       r0, 0(r10)

    br          END_VALIDATE_COMMAND

END_VALIDATE_COMMAND:
    ldw         fp, 0(sp)
    ldw         ra, 4(sp)
    addi        sp, sp, 8
    ret