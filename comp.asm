.include "SysCalls.asm"

.data
	space:		.asciiz " "
	newLine:	.asciiz "\n"
.text

.globl compMove

compMove:
	#random number
	li $v0, 41
	syscall
	
	# $a0 (random num) % 9  + 1 = random number from 1-9
	li $t0, 9
	rem $a0, $a0, $t0
	blt $zero, $a0 , notNeg		#is it negative?
	neg $a0, $a0			#make it positive
notNeg:
	addi $a0, $a0, 1		#add 1 to make it 1-9
	move $s5, $a0			#store comp's number
	
	# 50/50 on which dial to move
	#random number
	li $v0, 41
	syscall
	
	# $a0 % 2 = random number 0-1
	li $t0, 2
	rem $a0, $a0, $t0
	blt $zero, $a0 , notNeg2	#is it negative?
	neg $a0, $a0			#make the negative number positive
notNeg2:
	move $s4, $a0			#store comp's dial to edit
	
	j valid				#check if it's valid
