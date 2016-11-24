.include "constants.s"

# This procedure is responsible to rotate the 7-segment display left or right,
# considering what is in the ROTATION_DIRECTION_ADDRESS.
#
# This address will contain zero, if it is a rotation to the right, or will contain
# anything other than zero if it is a left rotation.
#
# This procedure is called on the timer interruption handler.

.global ROTATE_PHRASE
ROTATE_PHRASE:

  # Build the stack
  addi        sp, sp, -8
  stw         fp, 0(sp)
  stw         ra, 4(sp)
  addi        fp, sp, 0

  # Load current values in hex displays
  movia       r9, HEX_DISPLAY30_BASE_ADDRESS
  movia       r10, HEX_DISPLAY74_BASE_ADDRESS
  ldwio       r11, 0(r9)
  ldwio       r12, 0(r10)

  # Get the rotation direction (0 -> right, other -> left)
  movia       r13, ROTATION_DIRECTION_ADDRESS
  ldb         r14, 0(r13)
  beq         r14, r0, ROTATE_RIGHT

  # Execute rotation to the left
  movia       r13, LEFTMOST_BYTE_mask
  and         r14, r11, r13                     # Select HEX_DISPLAY_3
  srli        r14, r14, 24                      # Shift the selected byte to the rightmost byte
  and         r15, r12, r13                     # Select HEX_DISPLAY_7
  srli        r15, r15, 24                      # Shift the selected byte to the rightmost byte

  slli        r11, r11, 8                       # rotate HEX_DISPLAY30 one byte to the left
  slli        r12, r12, 8                       # rotate HEX_DISPLAY74 one byte to the left
  or          r11, r11, r15                     # Place saved HEX_DISPLAY_7 on HEX_DISPLAY_0
  or          r12, r12, r14                     # Place saved HEX_DISPLAY_3 on HEX_DISPLAY_4
  br END_ROTATE_PHRASE

ROTATE_RIGHT:

  # Execute rotation to the right
  movia       r13, RIGHTMOST_BYTE_mask
  and         r14, r11, r13                     # Select HEX_DISPLAY_0
  slli        r14, r14, 24                      # Shift the selected byte to the leftmost byte
  and         r15, r12, r13                     # Select HEX_DISPLAY_4
  slli        r15, r15, 24                      # Shift the selected byte to the leftmost byte

  srli        r11, r11, 8                       # rotate HEX_DISPLAY30 one byte to the right
  srli        r12, r12, 8                       # rotate HEX_DISPLAY74 one byte to the right
  or          r11, r11, r15                     # Place saved HEX_DISPLAY_0 on HEX_DISPLAY_7
  or          r12, r12, r14                     # Place saved HEX_DISPLAY_4 on HEX_DISPLAY_3
  br END_ROTATE_PHRASE

END_ROTATE_PHRASE:
  # Put rotated values back in the displays registers
  stwio       r11, 0(r9)
  stwio       r12, 0(r10)

  # Tear down the stack and return
  ldw         fp, 0(sp)
  ldw         ra, 4(sp)
  addi        sp, sp, 8
  ret