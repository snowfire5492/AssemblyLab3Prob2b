########################################################################
# Student: Eric Schenck						Date: 11/15/17
# Description: LabThreeProblem2b.asm - Write a function AVA(&X, &Y, &Z, n, s, t)
#		to perform absolute value vector addition, such that
#		Xi = |Yi| + |Zi| + 2 * s + t; 		for 0 <= i <= n-1
#		where &X, &Y, &Z refer to the array X,Y,Z's starting addrss, 
#		n is the size of the array, and s and t are integers.
#		
#		USE THE STACK TO PASS THESE SIX ARGUMENTS
#		
#		Write two main programs that call the AVA function
#		on the following data sets. Note: prepare two seperate
#		program files, one for each data set
#
#		For each data set, main should first print Y and Z arrays, then 
#		calculate X, and finally print out X array 						
#
# Registers Used:
#	$a0: Used to pass arguments into system services
#	$a1: Used to pass address of array to printFunction
#	$a2: Used to n value to printFunction
#	$t0: Used for various temporary values
#	$t1: Used to hold n value in function 
#	$t2: Used to hold s value in function
#	$t3: Used to hold t value in function
#	$t4: Used to hold arrayZ address in function 
#	$t5: Used to hold arrayY address in function
#	$t6: Used to hold arrayX address in function
#	$t7: Used to hold value at current index in arrayY
#	$t8: Used to hold value at current index in arrayZ
#	$t9: Used to hold value of sum of AVA equation 
#	$s0: Used to store n value for easy change out 
#	$s1: Used to store s value for easy change out 
#	$s2: Used to store t value for easy change out 
#	$v0: Used for system services codes
#
#
########################################################################
		.data
msgX:		.asciiz "\nX : "
msgY:		.asciiz "\nY : "
msgZ:		.asciiz	"\nZ : "
comma:		.asciiz ", "
arrayX:		.word 0:10
arrayY:		.word -1, 3, -5, 7, -9, 2, -4, 6, -8, 10
arrayZ:		.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

				
		.text
		.globl main
		
main:		li $s0, 10		# using to store n value for easy change
		li $s1, 3		# using to store s value for easy change
		li $s2, 2		# using to store t value for easy change		

		li $v0, 4
		la $a0, msgY		# msg for Y array printout
		syscall
		
		la $a1, arrayY		# loading address for arrayY into argument register for printFunction
		move $a2, $s0		# n loaded into argument register for printFunction
		jal printArray		# calling printFunction
		
		li $v0, 4
		la $a0, msgZ		# msg for Z array printout
		syscall
		
		la $a1, arrayZ		# loading address for arrayZ into $a1 for printFunction
					# n  still in register $a2 for printFunction
		jal printArray		# calling printFunction
		 		
		 				 				 		
		addi $sp, $sp, -24 	# to place 6 arguments in stack (6 x 4 = 24)
		la $t0, arrayX		# loading address of array X into $t0
		sw $t0, 20($sp)		# arrayX address to stack
		la $t0, arrayY		# loading address of array Y into $t0
		sw $t0, 16($sp)		# arrayY address to stack
		la $t0, arrayZ 		# loading address of array Z into $t0
		sw $t0, 12($sp)		# arrayZ address to stack
		sw $s0, 8($sp)		# n pushed onto stack
		sw $s1, 4($sp)		# s pushed onto stack
		sw $s2, 0($sp)		# t pushed onto stack
						
		jal AVA			# calling AVA(&X,&Y,&Z,n,s,t) function 
		
		li $v0, 4
		la $a0, msgX		# msg for X array printout
		syscall
		
		
		la $a1, arrayX		# loading address for arrayX into $a1 for printFunction
		move $a2, $s0		# n  loaded into argument register for printFunction
		jal printArray		# calling printFunction
		
						
Exit:		addi $sp, $sp, 24	
		
		li $v0, 10 			# System code to exit
		syscall				# make system call 

########################################################################
					# AVA(&X,&Y,&Z,n,s,t) function
		.text
		
AVA:		lw $t1, 0($sp)		# getting t from the stack
		lw $t2, 4($sp)		# getting s from the stack
		lw $t3, 8($sp)		# getting n from the stack
		lw $t4, 12($sp)		# address of arrayZ from stack into $t4
		lw $t5, 16($sp)		# address of arrayY from stack into $t5
		lw $t6, 20($sp)		# address of arrayX from stack into $t6

loop:		
		beqz $t3, return	# if ( n = 0 ) leave loop
				
		lw $t7, 0($t5)		# getting value at arrayY index
		abs $t7, $t7		# absolute value of Y entry
		
		lw $t8, 0($t4)		# getting value at arrayZ index
		abs $t8, $t8		# absolute value of Z entry
		
		sll $t9, $t2, 1		# multiplying s by 2 and storing in $t9
		add $t9, $t9, $t1	# $t9 = (s*2) + t
		add $t9, $t9, $t8	# $t9 = |Zi| + (s*2) + t
		add $t9, $t9, $t7	# $t9 = |Yi| + |Zi| + (s*2) + t
		
		sw $t9, 0($t6)		# Xi = $t9 ( storing $t9 in arrayX at correct index
		
		addi $t3, $t3, -1	# decriment n value in temp register to keep track of loops
		addi $t6, $t6, 4	# update location in arrayX
		addi $t5, $t5, 4	# update location in arrayY
		addi $t4, $t4, 4	# update location in arrayZ
		
		j loop 			# continue in loop until branch at top exits 

return:		
		jr $ra			# returning from function		
		
#####################################################################
					# printArray(Array: $a1, N: $a2)

printArray:	
		move $t2, $a2		# value of n is now stored in $t2
		addi $t3, $t2, -1	# value of $t3 = n-1 ( used to format the comma printout )
		
printLoop:	
		beqz $t2, returnP	# if n = 0 then exit printFunction	
		lw $t1, 0($a1)		# loading the value of array at current index location
		
		addi $a1, $a1, 4	# adjusting array location for next term
		addi $t2, $t2, -1	# decrimenting n value
		
		li $v0, 1
		move $a0, $t1		# moving $t1 into $a0 to print integer value 
		syscall
		
		beqz $t3, returnP	# if $t3 = 0 then stop printing commas (note: $t3 = n-1)
		addi $t3, $t3, -1	# decrimenting comma counter 
		
		li $v0, 4
		la $a0, comma		# using string printout to separate integer values by a comma
		syscall
		 
		j printLoop		# continuing to loop
		
returnP:	jr $ra









