/*********************************************************************************
 * Final Project for the course of Microprocessors II                            *
 * 2BYTES_BIN_TO_5BYTES_HEXDISPLAY.s                                             *
 * This is an auxiliary method to the final projetc                              *
 * Input will be 2 bytes long, as unsigned integer (0 ~ 65535)                   *
 * The OUTPUT is a 7-display-segment DECIMAL representation of that input        *
 * that will require 5 digits to be represented.                                 *
 * This OUTPUT will be 5 bytes long (one byte for each digit).                   *
 * Example:                                                                      *
 * Input: 0011 0101 0111 1111[2] ( 13695[10] )                                   *
 * Output: 00 00 00 06 4F 7D 6F 6D (8 BYTES - 5 significant)                     *
 *         __ __ __  1  3  6  9  5 (Hex-Display)                                 *
 * Input: r4                                                                     *
 * Output: r2 (4 less significant digits) r3 (most significant significant digit)*
 * 2016/10/17 (not tested)                                          *
 * Professor: Joao Paulo L de Carvalho                                           *
 * Authors:                                                                      *
 * Dalton Lima @daltonbr                                                         *
 * Giovanna Cazelato @giovannaC                                                  *
 * Lucas Pinheiro @lucaspin                                                      *
 *********************************************************************************/

.equ DIGIT_CODE_MAP, 0x20000          # base address for our table of outputs
.equ MASK,           0xff

.global 2BYTES_BIN_TO_5BYTES_HEXDISPLAY
2BYTES_BIN_TO_5BYTES_HEXDISPLAY:
	
	/* prologue */
	addi    sp, sp, -8
	stw     fp, 0(sp)
	stw     ra, 4(sp)
	addi    fp, sp, 0

    add     r8, r0, r4              # r8 will be our placeholder
    addi    r12, r0, DIGIT_CODE_MAP # Pointer to the map in memory
    add     r3, r0, r0
    
/* This method uses the integer division and the remainder, using this pattern:
    divu rC, rA, rB # original divu operation
    mul rD, rC, rB
    sub rD, rA, rD # rD = remainder
*/

    /* HEX4 */
    movia   r9, 10000
    divu    r10, r8, r9             # r10 = input / 10000 (unsigned integer division)
    add     r13, r12, r10           # r13 (pointer) = base_address + offset
    ldb     r3, 0(r13)              # loading the value - exceptionally in r3
    mul     r11, r10, r9            # r11 = integer_division(r10) * 10000 
    sub     r8, r8, r11             # r11 (remainder) = input - integer_division

    /* HEX3 */
    movia   r9, 1000
    divu    r10, r8, r9
    add     r13, r12, r10
    ldb     r13, 0(r13)              # temporally loading the value in r13
    slli    r13, r13, 24             # shift the digit to its desired position
    or      r2, r2, r13              # merge the new digit into the output (r2)
    mul     r11, r10, r9 
    sub     r8, r8, r11

    /* HEX2 */
    movia   r9, 100
    divu    r10, r8, r9
    add     r13, r12, r10
    ldb     r13, 0(r13)              # temporally loading the value in r13
    slli    r13, r13, 16             # shift the digit to its desired position
    or      r2, r2, r13              # merge the new digit into the output (r2)
    mul     r11, r10, r9 
    sub     r8, r8, r11

    /* HEX1 */
    movia   r9, 10
    divu    r10, r8, r9
    add     r13, r12, r10
    ldb     r13, 0(r13)              # temporally loading the value in r13
    slli    r13, r13, 8              # shift the digit to its desired position
    or      r2, r2, r13              # merge the new digit into the output (r2)
    mul     r11, r10, r9 
    sub     r10, r8, r11             # this last remainder will be the last digit
    
    /* HEX0 */
    add     r13, r12, r10
    ldb     r13, 0(r13)              # temporally loading the value in r13
    or      r2, r2, r13              # merge the new digit into the output (r2)
                  
	/* epilogue */
	ldw     fp, 0(sp)
	ldw     ra, 4(sp)
	addi    sp, sp, 8
	ret

.org DIGIT_CODE_MAP
VALUES:
.byte   0x3f, 0x06, 0x5b, 0x4F, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f

# table values for conversion to 7-display segment
 # 0 - (0,1,2,3,4,5) = 		0011 1111 = 0x3f
 # 1 - (1,2) = 				0000 0110 = 0x06
 # 2 - (0,1,3,4,6) = 		0101 1011 = 0x5b
 # 3 - (0,1,2,3,6) = 		0100 1111 = 0x4F
 # 4 - (1,2,5,6) = 			0110 0110 = 0x66
 # 5 - (0,2,3,5,6) = 		0110 1101 = 0x6d
 # 6 - (0,2,3,4,5,6) = 		0111 1101 = 0x7d
 # 7 - (0,1,2) = 			0000 0111 = 0x07
 # 8 - (0,1,2,3,4,5,6) =	0111 1111 = 0x7f
 # 9 - (0,1,2,3,5,6) = 		0110 1111 = 0x6f
 
.end