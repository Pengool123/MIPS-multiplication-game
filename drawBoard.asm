.include "SysCalls.asm"

.data
	space:		.asciiz " "
	doubleSpace:	.asciiz "  "
	newLine:	.asciiz "\n"
.text

.globl draw

#draw the board
draw:
	li $t1,0	#row
	
resetCol:
	li $t2, 0	#col

loop:
	#address [row][col]
	#6 per row, multiples of 6 will be the row cut off
	mul $t3, $t1, 6		#row * 6
	add $t3, $t3, $t2	#row * 6 + col
	sll $t3, $t3, 2
	
	add $t4, $s0, $t3	# $t4 = address of current  matrix[row][col]
	
	lw $a0, 0($t4)		#load value
	
	#check if it's a number
	move $t5, $a0
	li $s6, 82
	blt $t5, $s6, num	#if it's a number
	li $v0, SysPrintString	#not a num, print string and another space
	syscall
	la $a0, space		#print the space
	li $v0, SysPrintString
	syscall
	j movingOn		#go past print int
num:
	li $v0, SysPrintInt	#print the number
	syscall
movingOn:
	#if it need to have 1 or 2 spaces based on length
	li $t6, 10
	blt $t5, $t6, twoSpace
	
#print 1 space
oneSpace:
	la $a0, space
	li $v0, SysPrintString
	syscall
	j cont

#print 2 spaces
twoSpace:
	la $a0, doubleSpace
	li $v0, SysPrintString
	syscall
	
cont:
	addi $t2, $t2, 1	#Inc col number
	
	blt $t2, 6, loop	#Next col until the end
	
	#next row
	
	la $a0, newLine		#load new line
	li $v0, SysPrintString	#print new line
	syscall
	
	addi $t1, $t1, 1	#next row
	
	blt $t1, 6, resetCol	#reset the col count and loop

	la $a0, newLine		#load new line
	li $v0, SysPrintString	#print new line
	syscall

	jr $ra		#return to caller
