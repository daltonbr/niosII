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

    # calculate triangular number
    call        TRIANGULAR

    # TODO: display in the 7-segment display
    add         r4, r0, r2
    call        TWO_BYTES_BIN_TO_5BYTES_HEXDISPLAY

    movia       r9, HEX_DISPLAY30_BASE_ADDRESS
    movia       r10, HEX_DISPLAY74_BASE_ADDRESS
    stwio       r2, 0(r9)
    stwio       r3, 0(r10)

    br          END_VALIDATE_COMMAND

TWO_ZERO_COMMAND:
    # TODO
    br          END_VALIDATE_COMMAND

TWO_ONE_COMMAND:
    # TODO
    br          END_VALIDATE_COMMAND

END_VALIDATE_COMMAND:
    ldw         fp, 0(sp)
    ldw         ra, 4(sp)
    addi        sp, sp, 8
    ret