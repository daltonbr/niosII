/*********************************************************************************
 * Final Project for the course of Microprocessors II                            *
 * triangular.s                                                                  *
 * This is an auxiliary method to the final projetc                              *
 * Input: r4 (8 bit unsigned integer to be calculated the triangular number)     *
 *       0 ~ 255                                                                 *
 * Output: r2 (16 bit unsigned integer) - max value x(511) = 32640               *
 * Version 0.2 - 2016/10/17                                                      *
 * Professor: Joao Paulo L de Carvalho                                           *
 * Authors:                                                                      *
 * Dalton Lima @daltonbr                                                         *
 * Giovanna Cazelato @giovannaC                                                  *
 * Lucas Pinheiro @lucaspin                                                      *
 *********************************************************************************/
    .global TRIANGULAR
TRIANGULAR:

/* This subroutine calculates a triangular number given an integer
 * We use the following formula: 
 *   x(n) = n(n+1)/2 
 */

/* prologue */
	addi    sp, sp, -8
	stw     ra, 4(sp)
	stw     fp, 0(sp)
	addi    fp, sp, 0

/* start of the function */
# Confirm: MUL is implement in this version of NIOS II ?
    add     r2, r0, r4                      # r2 = n
    add     r9, r0, r4
    addi    r9, 1                           # r9 = n+1
    mul     r2, r2, r9                      # r2 = n * (n+1) 
    addi    r9, r0, 2                       # r9 = 2
    divu    r2, r2, r9                      # r2 = n * (n+1) / 2
    
/* epilogue */
    ldw     fp, 0(sp)
    ldw     ra, 4(sp)
    addi    sp, sp, 8
    ret

.end