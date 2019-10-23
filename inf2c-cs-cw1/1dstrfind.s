#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
space:                	.asciiz  " "
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

no_word_found:		.word 1

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   	$v0, 16                    # system call for close file
        move 	$a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------






	move 	$t1 $0			#dictionary index
	move 	$t0 $0			#grid index
	move	$t4 $0			#grid index -> this index will alway point at the current grid character and only 
					#updates if the dictionary has reached endoffile EOF
	move	$t5 $0			#dictionary word counter -> used to print the word found
		
	lb   	$s2, newline		#endofline
	lb   	$s3, space		#space
	lw	$s4, no_word_found	#storing no_word_found (acting as a boolean)

grid_loop:

	li   	$v0, 11			# grid character
	lb	$t2, grid($t0)
        move   	$a0, $t2          	# address of buffer from which to read
	
	blez 	$t2, done		# end of file reached - go to end_grid
	
	#beq  	$t2, $v0, done		# branch if end of line is found (maybe its not necesssary as the grid is one dimentional
	
	#syscall				#output (debug)
	
	j 	dictionary_compare	#comparing grid char with dictionary for potential word
	
next_grid_char_eof:

	addi	$t4, $t4, 1		#only updates when dictionary reaches end of file
	
	addi 	$t0, $t0, 1		#next grid char
	
word_found_repeat_char:

	move	$t1 $0			#resetting dictionrary
	
	move 	$t5, $0			#reset word counter
	
	j    	grid_loop
	
next_grid_char:				#character matches.
	
	addi 	$t0, $t0, 1		#next grid char
	
	addi 	$t1, $t1, 1		#next dictionary char
		
	j    	grid_loop
	
end_grid:

	move	$t0 $0
	
dictionary_compare:

	li	$v0, 11
	lb	$t3, dictionary($t1)
        move 	$a0, $t3            	# address of buffer from which to read
        
        #syscall
        
        beq	$t3, $s2, word_found	#dictionary endofline -> means word has been founnd
                

        beq	$t2, $t3, next_grid_char	#grid char and dictionary char match -> move to the next grid and dictionary character
        
        move 	$t0, $t4			#back to the first character of the "potential mathcing word"
        
        lb	$t2, grid($t0)			#restart to the grid character just before the comparition begun
        
        
        
dictionary_iterate_till_newline:		#iterating untill end of line is found to move to next word

	addi	$t1, $t1, 1
	lb	$t3, dictionary($t1)
	
	li	$v0, 11
        move	$a0, $t3
        
        #syscall
        
	li	$v0, 11
        move	$a0, $s2
        
        #syscall
        
        blez	$t3, next_grid_char_eof		# end of file, move to next grid character
	
	beq 	$t3, $s2, dictionary_next_word 	#new line
	
	j	dictionary_iterate_till_newline

dictionary_next_word:
	
	addi	$t1, $t1, 1 			#increment to first char of next word
	
	move	$t5, $t1			#increment next word
	
	j	dictionary_compare
	
	
word_found:
	
	li 	$s0, 1
	
	li	$v0, 1
        move	$a0, $t4
        syscall
        
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        li	$s4, 0
        
        
print_word_found:				#printing character

	li	$v0, 11
	lb	$a0, dictionary($t5)
	syscall
	
	addi	$t5, $t5, 1
	
	bne	$a0, $s2, print_word_found
	
	
        move	$t5, $t1

        move	$t0, $t4
        lb	$t2, grid($t0)
        addi	$t5, $t5, 1			#increment next word
        
        j 	dictionary_iterate_till_newline

done:
						#checking if the last characters of grid represent a word	
	lb	$t3, dictionary($t1)
        blez	$t3, word_found
        beq	$t3, $s2, word_found
        
        beq	$s4, 1, no_words_found_output	#no words found -> print -1
        
exit:						#program termination			

	li      $v0, 10
    	syscall   
    	
no_words_found_output:				#print -1

	li      $v0, 1
	li      $a0, -1
    	syscall   
    	
    	j exit
	
	
#print_grid:

#	li      $v0, 4 
#	la      $a0, dictionary($t0)
#	syscall

#	addi $t0, $t0, 1

# You can add your code here!
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
