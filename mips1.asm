.include "SysCalls.asm"
.data
	userP:		.space 1
	
	space:		.asciiz " "
	newLine:	.asciiz "\n"
	
	matrix:		.word 	1,2,3,4,5,6,
				7, 8,9,10,12,14, 
				15,16,18,20,21,24,
				25,27,28,30,32,35,
				36,40,42,45,48,49,
				54,56,63,64,72,81
	dial: 		.asciiz "Current dials: "
	dialIn:		.asciiz "\nWhich dial would you like to input into? (0 = left, 1 = right): \n"
	whichNum:	.asciiz "What is your number (1-9): \n"
	
	playerWin:	.asciiz "You Won!"
	compWin:	.asciiz "The Computer Won :("
	
.text
	la $s0, matrix	#address for matrix
	li $s1, 1	#dial 1
	li $s2, 1	#dial 2
	li $s3, 0	# 0 = comp move, 1 = player move
	#$s4 holds the dial to edit
	#$s5 holds the number the dial will move to
	#$s6 holds temp blt values to compare
	#$s7 is a backup incase the move is invalid

.globl play
.globl playerMove
.globl win
.globl end

play:
	#make comp play a move
	jal compMove

playerMove:
	#draw matrix in drawBoard.asm
	jal draw
	
	#print new line
	la $a0, newLine
	li $v0, SysPrintString
	syscall
	
	#print the current dials
	la $a0, dial
	li $v0, SysPrintString
	syscall
	
	#print dial 1
	move $a0, $s1
	li $v0, SysPrintInt
	syscall
	
	#print space
	la $a0, space
	li $v0, SysPrintString
	syscall
	
	#print dial 2
	move $a0, $s2
	li $v0, SysPrintInt
	syscall
	
	#print player dial input
	la $a0, dialIn
	li $v0, SysPrintString
	syscall
	
	#get input
	li $v0, SysReadInt
	syscall
	move $s4, $v0
	
	
	#print number input
	la $a0, whichNum
	li $v0, SysPrintString
	syscall
	
	#to what number
	li $v0, SysReadInt
	syscall
	move $s5, $v0
	
	#player check
	j playerInValid

#someone won
win:
	beq $s3, 0, compW		#if it's the computer, jump to compW, else it's the player's win
	la $a0, playerWin		#Print the victory message
	li $v0, SysPrintString
	syscall
	j end				#end the program
	
compW:
	la $a0, compWin			#print the comp's victory message
	li $v0, SysPrintString
	syscall

	
end:
	la $v0, SysExit			#end program
	syscall
