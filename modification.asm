.include "SysCalls.asm"

.data
	space:		.asciiz " "
	newLine:	.asciiz "\n"
	compOwn:	.asciiz "*"
	playerOwn:	.asciiz "%"
	playerError:	.asciiz "not a valid move, try again\n"
	
	currow:		.asciiz "row: "
	curcol:		.asciiz "col: "
.text

.globl valid
.globl playerInValid

#check if the player's input is 1-10
playerInValid:
	li $s6, 10
	blt $s6, $s5, notValid		#is not in range
	j valid				#is valid

#not valid, print error msg
notValid:
	la $a0, playerError
	li $v0, SysPrintString
	syscall
	j playerMove			#back to player's input

#check if the move is valid for both comp and player
valid:
	beq $s4, $zero, fst		#0 = 1st dial, else its 2nd dial
#if the 2nd one was to be edited
secnd:
	mul $t0, $s1, $s5		#multiply dial 1 and inputed dial 2
	j cont 
#if the 1st one was to be edited
fst:
	mul $t0, $s2, $s5		#multiply dial 2 and inputed dial 1

cont:
	li $t1,0	#row
	
resetCol:
	li $t2, 0	#col

#loop through the matrix to find the number
loop:
	#address [row][col]
	#6 per row, multiples of 6 will be the row cut off
	mul $t3, $t1, 6		#row * 6
	add $t3, $t3, $t2	#row * 6 + col
	sll $t3, $t3, 2
	
	add $t4, $s0, $t3	# $t4 = address of current  matrix[row][col]
	
	lw $a0, 0($t4)		#load value
	
	move $t5, $a0
	
	beq $t5, $t0, playMove	#number found, play it
	
	addi $t2, $t2, 1	#Inc col number
	
	blt $t2, 6, loop	#Next col until the end
	
	#next row
	
	la $a0, newLine		#load new line
	li $v0, SysPrintString	#print new line
	syscall
	
	addi $t1, $t1, 1	#next row
	
	blt $t1, 6, resetCol	#reset the col count and loop
	
	#not a valid move
	#comp end
	beq $s3, 0, play
	
	#player end
	#print new line
	la $a0, newLine
	li $v1, SysPrintString
	syscall
	#print error message
	la $a0, playerError
	li $v1, SysPrintString
	syscall
	j playerMove
	
playMove:
	#if it's the comp's move, jump, else it's the player's
	beq $s3, 0, comp
	#own the spot
	la $t0, playerOwn	#store player's sign
	sw $t0, 0($t4)		#put the sign in
	jal checkWin		#check if it's a winning move
	li $s3, 0		#make the move set to comp's
	jal editDial		#edit dial
	j play			#jump to computer's move
	
comp:
	#own the spot
	la $t0, compOwn		#store comp's sign
	sw $t0, 0($t4)		#put the sign in
	jal checkWin		#check if it's a winning move
	li $s3, 1		#set to player's move
	jal editDial		#edit dial
	j playerMove		#jump to player's move
	
#edit the dial
editDial:
	beq $s4, $zero, fst2	#which dial to edit
#2nd dial is to be edited
secnd2:
	move $s2, $s5		#dial 2 = inputed move
	jr $ra			#jump back to whoever's move it was
fst2:
	move $s1, $s5		#dial 1 = inputed move
	jr $ra			#jump back to whoever's move it was
	
#check if this was a winning move
checkWin:
	#store the location
	move $t7, $t1	#row
	move $t6, $t2	#col
	
	li $t1, 0	#temp row
	li $t2, 0	#temp col
	li $t5, 0	#how many in a row

horz:
	mul $t3, $t7, 6		#go to row
	add $t3, $t3, $t2	#add temp col
	sll $t3, $t3, 2
	
	add $t3, $t3, $s0	#go to board location
	lw $a0, 0($t3)		#load the word
	move $t4, $a0		#move it to compare
	
	beq $t4, $t0, count	#if it's the turn's sign, add 1, else go down to 0
	j nope

#sign found
 count:
 	 addi $t5, $t5, 1	#+1 to counter
 	 j con2
#not a sign, reset counter
 nope:
 	li $t5, 0		#counter = 0
 
 con2:
 	beq $t5, 3, win		#if counter is a 3, someone won
 	addi $t2, $t2, 1	#next col
 	beq $t2, 6, vert	#if row is fully checked, check vertical
 	j horz			#loop and check horizontal
 
 vert:
 	
 	mul $t3, $t1, 6		#go to row
	add $t3, $t3, $t6	#add col
	sll $t3, $t3, 2		#4 bytes a word
	
	add $t3, $t3, $s0	#go to board location
	lw $a0, 0($t3)		#load word
	move $t4, $a0		#move it to compare
	
	beq $t4, $t0, count2	#if it a sign +1
	j nope2			#else reest counter
	
count2:
 	 addi $t5, $t5, 1	#+1 to counter
 	 j con3
 nope2:
 	li $t5, 0		#reset to 0
 
 con3:
 	beq $t5, 3, win		#check if counter = 3 for win
 	addi $t1, $t1, 1	#next row
 	li $s6, 6		#hold for compare
 	beq $t1, $s6, out	#if it's at the end, no win
 	j vert
 out:
 	jr $ra			#continue the game
