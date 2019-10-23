
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

space:                	.asciiz  " "
comma:                	.asciiz  ","
horizontal:		.asciiz "H"
vertical:		.asciiz "V"
diagnonal:		.asciiz "D"
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

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!

	move 	$t0 $0			# grid_idx
	move 	$t1 $0			# * match word
	move	$t2 $0			# dict_char
	move	$t3 $0			# max_grid_height
	li	$t4 1			# row	
	move	$t5 $0			# grid_clm
	move	$t6 $0			# max_grid_length
	move	$t7 $0			# grid_char
	move	$t8 $0			# * match_row
	move	$t9 $0			# * word
	
	lb	$s1, comma		#comma
	lb   	$s2, newline		#endofline
	lb   	$s3, space		#space
	lw	$s4, no_word_found	#storing no_word_found (acting as a boolean)
	lb	$s5, horizontal
	lb	$s6, vertical
	lb	$s7, diagnonal


#####################################
######## Horizontal Search ##########
#####################################
        
        

while_not_end_of_grid:

	lb 	$t7 grid($t0)		# get current grid char

	blez	$t7 vertical_search	# end of grid file
	
	lb	$t2, dictionary($0)
	move	$t9 $0
	
	lb 	$t7 grid($t0)
	
	# store to update max_grid_length
	bne 	$t7 $s2 while_dict_not_new_line
        
	addi	$t4 $t4 1		# row++;
	addi	$t5 $t5 1		# grid_clm+1;
	move	$t6 $t5
	move	$t5 $0
	addi	$t0 $t0 1
	
	j 	while_dict_not_new_line

while_dict_not_new_line:
	
	lb 	$t2 dictionary($t9)	# * word
	
	beq	$t2 $s2 h_next_grid_idx	# * word != '\n'
	
	move	$t8 $t0
	move	$t1 $t9
	
	lb	$t7 grid($t0)
	lb	$t2 dictionary($t1)
	
h_while_potential_match_found:		# *match_word == *grid_char
	
	bne 	$t2 $t7 h_next_dict_word
	blez	$t2 h_next_dict_word
	blez	$t7 h_next_dict_word
	
	addi	$t8 $t8 1		# match_clm++;
	addi	$t1 $t1 1		# match_word++;

	lb	$t7 grid($t8)		# * match_clm
	lb	$t2 dictionary($t1)	# * match_word
	
	beq	$t2 $s2 h_word_match_found
	blez	$t2 h_word_match_found
	
	j h_next_dict_char
		
h_word_match_found:
	
	# temporarely moving row to t1 to output $t1 -1
	move	$t1 $t4
	subi	$t1 $t1 1
	
	li	$v0, 1
        move	$a0, $t1
        syscall
        
       	# comma
        li	$v0, 11
        move	$a0, $s1
        syscall
        
        # column
	li	$v0, 1
        move	$a0, $t5
        syscall
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        # horizontal
        li	$v0, 11
        move	$a0, $s5
        syscall
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        move	$t1 $t9
        lb	$t2 dictionary($t1)
     
while_printing_new_word:

	lb	$t2 dictionary($t1)
	
	beq	$t2 $s2 printed_word_new_line
	blez 	$t2 printed_word_new_line
	
	li	$v0, 11
        move	$a0, $t2
        syscall
        
        addi 	$t1 $t1 1
        
        j while_printing_new_word

printed_word_new_line:

	li	$v0, 11
        move	$a0, $s2
        syscall
	
	li 	$s4 1
	
	j 	h_while_potential_match_found
	
h_next_dict_char:
	
	beq	$t8 $s2 h_next_dict_word

	lb	$t7 grid($t8)
	
	j	h_while_potential_match_found

h_next_dict_word:

	lb	$t2 dictionary($t9)
	beq	$t2 $s2 h_check_EOF_dictionary
	blez 	$t2 h_check_EOF_dictionary
	
	addi 	$t9 $t9 1
	
	j 	h_next_dict_word

# next dictionary word
h_check_EOF_dictionary:

	lb	$t2 dictionary($t9)
	blez 	$t2 h_next_grid_idx		# branch if *word == '\0'
	
	addi 	$t9 $t9 1
	
	j 	while_dict_not_new_line
	
h_next_grid_idx:

	addi	$t0 $t0 1
	addi	$t5 $t5 1
	
	lb	$t7 grid($t0)
	
	bne	$t7 $s2 while_not_end_of_grid
	
	addi	$t5 $t5 1
	move	$t6 $t5
	
	j while_not_end_of_grid
	
	

#####################################
######### Vertical Search ###########
#####################################


vertical_search:


	addi 	$t0 $t0 1
	
	move	$t3 $t4			# max_grid_height
	
	div 	$t6 $t0 $t3		# max_grid_length

	move 	$t0 $0			# grid_char
	move	$t9 $0			# *word
	move 	$t1 $0			# *match_word
	lb	$t2, dictionary($t9)	# first word from dictionary - word
	
	move	$t4 $0			# row = 0
	move	$t5 $0			# grid_clm - 0
	move 	$t8 $0			# match_row


while_grid_not_newline:

	lb 	$t7 grid($t5)		# get current grid char
	
	beq 	$t7 $s2 diagnonal_search	# branch if grid[grid_clm] == '\n'
	blez 	$t7 diagnonal_search		# branch if grid[grid_clm] == '\0'
	
	move 	$t4 $0
	
while_row_not_max:	
	
	bge 	$t4 $t3 next_column 		# branch if row >= max_grid_height
	
	lb	$t2, dictionary($0)		# word     - first char from dictionary
	move	$t9 $0
	
while_word_not_newline:

	blez 	$t2 next_row_ver		# branch if word == \0
	
	move	$t8 $t4				# int match_row = row
	move	$t1 $t9				# match_word = word
	
	mul	$t0 $t6 $t8
	addu 	$t0 $t0 $t5
	
	lb	$t2, dictionary($t1)		# *match_word
	lb	$t7, grid($t0)			# *grid_char
	
	#beq 	$t2 $s2 next_row_ver
	
while_potential_match_found:	
	
	bne	$t2 $t7 next_dictionary_word	# *match_word == *grid_char

	
while_not_end_of_word:

	beq	$t2 $s2 check_EOF_dictionary
	blez 	$t2 check_EOF_dictionary
	
	addi 	$t8 $t8 1			# match_row++
	addi 	$t1 $t1 1			# match_word++
	
	lb	$t2, dictionary($t1)		# *match_word
	
	beq 	$t2 $s2, match_word_found
	blez 	$t2, match_word_found
	
	j	next_char_for_potential_match
	
match_word_found:

	move	$t1 $t9
	
	# row
	li	$v0, 1
        move	$a0, $t4
        syscall
        
       	# comma
        li	$v0, 11
        move	$a0, $s1
        syscall
        
        # column
	li	$v0, 1
        move	$a0, $t5
        syscall
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        # vertical
        li	$v0, 11
        move	$a0, $s6
        syscall
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
print_found_word:

	lb	$t2, dictionary($t1)		# *match_word
	
	beq 	$t2 $s2 finish_printing_found_word
	blez 	$t2 finish_printing_found_word
	
	li	$v0, 11
        move	$a0, $t2
        syscall
        
        addi 	$t1 $t1 1
        
        j	print_found_word
	
finish_printing_found_word:

	li	$v0, 11
        move	$a0, $s2
        syscall
        					#word found is 1
        j while_potential_match_found
	
	
next_char_for_potential_match:

	bge	$t8 $t3 next_dictionary_word

	mul	$t0 $t6 $t8
	add 	$t0 $t0 $t5

	lb	$t7 grid($t0)
	
	j	while_potential_match_found
	
	
next_dictionary_word:

	lb	$t2 dictionary($t9)
	beq	$t2 $s2 check_EOF_dictionary
	blez 	$t2 check_EOF_dictionary
	
	addi 	$t9 $t9 1
	
	j 	next_dictionary_word
	

# next dictionary word
check_EOF_dictionary:

	bnez 	$t2 next_word		# branch if *word != '\0'
	
	j 	next_row_ver
	
next_word:
	
	addi 	$t9 $t9 1
	
	j 	while_word_not_newline

#next grid row
next_row_ver:

	addi 	$t4 $t4 1
	
	j while_row_not_max

#next grid column	
next_column:
	
	addi 	$t5 $t5 1
	
	j while_grid_not_newline
	
	
	
	
	
######################################
######### Diagnonal Search ###########
######################################
	
diagnonal_search:




	addi 	$t0 $t0 1

	move 	$t0 $0			# *grid_char
	move	$t9 $0			# *word
	move 	$t1 $0			# *match_word
	lb	$t2, dictionary($t9)	# first word from dictionary - word
	
	move	$t4 $0			#d_ row = 0
	move	$t5 $0			# grid_init - 0
	move 	$t8 $0			# match_row
	
	move	$s7 $0			# grid_init_row track


d_while_grid_is_within_grid:

	lb 	$t7 grid($t5)		# get current grid char
	
	mul	$t9 $t3 $t6		# (temporary) grid max position
	bge 	$t5 $t9 exit		# branch if grid[grid_clm] == '\n'
	
	move 	$t4 $0
	
d_while_row_not_max:	
	
	move	$t9 $0
	addu	$t9 $t5 $t4		# (temporary) grid_init + d_row
	
	move	$t1 $0			# (temporary) max_grid_height
	subi	$t1 $t6 1		# max_grid_length - 1
	
	bge 	$t4 $t3 d_next_column 		# branch if d_row < max_grid_height
	bgt  	$s7 0	d_while_row_not_max_cont# grid_init_row > 0
	bge 	$t9 $t1 d_next_column		# d_row + grid_init >= max_grid_length - 1
	bne 	$s7 0	d_next_column		# grid_init_row != 0

d_while_row_not_max_cont:
		
	lb	$t2, dictionary($0)		# * word     - first char from dictionary
	move	$t9 $0				# word = 0
	
d_while_word_not_newline:

	blez 	$t2 d_next_row_ver		# branch if word == \0
	
	move	$t8 $t4				# int match_row = row	
	
	bne 	$s7 0 d_while_word_not_newline_cont
	
bottom_left_triangle:
	
	move	$t1 $0				# (temporary) match_d_row
	subu	$t1 $t4 $s7			# d_row - grid_init_row
	
	move	$t8 $t1				# match_d_row = d_row - grid_init_row
	
	
d_while_word_not_newline_cont:

	move	$t1 $t9				# match_word = word
	
	addi	$t6 $t6 1			# max_grid_length + 1
	mul	$t0 $t6 $t8			# (max_grid_length + 1)*match_d_row
	addu 	$t0 $t0 $t5			# grid_init + (max_grid_length + 1)*match_d_row
	subu 	$t6 $t6 1			# resetting max height (max height -1)
	
	lb	$t2, dictionary($t1)		# *match_word
	lb	$t7, grid($t0)			# *grid_char
	
	#beq 	$t2 $s2 next_row_ver
	
d_while_potential_match_found:	
	
	bne	$t2 $t7 d_next_dictionary_word	# *match_word == *grid_char

	
d_while_not_end_of_word:

	beq	$t2 $s2 d_check_EOF_dictionary
	blez 	$t2 d_check_EOF_dictionary
	
	addi 	$t8 $t8 1			# match_row++
	addi 	$t1 $t1 1			# match_word++
	
	lb	$t2, dictionary($t1)		# *match_word
	
	beq 	$t2 $s2, d_match_word_found
	blez 	$t2, d_match_word_found
	
	j	d_next_char_for_potential_match
	
d_match_word_found:
	
	# row
	
	# (temporary) d_row = d_row + grid_init_row
	
	addu	$t4 $t4 $s7
	
	li	$v0, 1
        move	$a0, $t4
        syscall
        
        # resetting d_row (to its value before (temporary)
        subu	$t4 $t4 $s7
        
       	# comma
        li	$v0, 11
        move	$a0, $s1
        syscall
        
        # (temporary) max_grid_length + 1
        
        subi	$t6 $t6 1
        
        blt 	$t5 $t6 first_row_printing
        
     	li	$v0, 1
        move	$a0, $t4
        syscall   
        
        addi	$t6 $t6 1
        
        j	d_match_word_found_cont
 
first_row_printing:
       
        # column
        addu	$t1 $t5 $t4	# (temporary) print grid_init + d_row
        
	li	$v0, 1
        move	$a0, $t1
        syscall
        
        addi	$t6 $t6 1
        
d_match_word_found_cont:
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        lb	$t1 diagnonal
        
        # diagnonal
        li	$v0, 11
        move	$a0, $t1
        syscall
        
        # space
        li	$v0, 11
        move	$a0, $s3
        syscall
        
        move	$t1 $t9
        
d_print_found_word:

	lb	$t2, dictionary($t1)		# *match_word
	
	beq 	$t2 $s2 d_finish_printing_found_word
	blez 	$t2 d_finish_printing_found_word
	
	li	$v0, 11
        move	$a0, $t2
        syscall
        
        addi 	$t1 $t1 1
        
        j	d_print_found_word
	
d_finish_printing_found_word:

	li	$v0, 11
        move	$a0, $s2
        syscall
        					#word found is 1
        j 	d_while_potential_match_found
	
	
d_next_char_for_potential_match:

	addu	$s5 $t5 $t8			#grid_init + match_d_row

	bge	$t8 $t3 d_next_dictionary_word
	blt	$s5 $t6 d_next_char_for_potential_match_cont
	bne  	$s7 0 d_next_char_for_potential_match_cont
	
	j	d_next_dictionary_word

d_next_char_for_potential_match_cont:

	mul	$t0 $t6 $t8
	addu 	$t0 $t0 $t5
	addu 	$t0 $t0 $t8

	lb	$t7 grid($t0)
	
	j	d_while_potential_match_found
	
	
d_next_dictionary_word:

	lb	$t2 dictionary($t9)
	beq	$t2 $s2 d_check_EOF_dictionary
	blez 	$t2 d_check_EOF_dictionary
	
	addi 	$t9 $t9 1
	
	j 	d_next_dictionary_word
	

# next dictionary word
d_check_EOF_dictionary:

	bnez 	$t2 d_next_word		# branch if *word != '\0'
	
	j 	d_next_row_ver
	
d_next_word:
	
	addi 	$t9 $t9 1
	
	j 	d_while_word_not_newline

#next grid row
d_next_row_ver:

	addi 	$t4 $t4 1
	
	j d_while_row_not_max

#next grid column	
d_next_column:
	
	move  	$s6 $t6
	subi	$s6 $s6 1
	
	bgt 	$t5 $s6 d_next_row
	
	addi 	$t5 $t5 1
	
	bne 	$t5 $s6 d_while_grid_is_within_grid #grid_init = \n
	
	addi	$t5 $t5 1
	addi	$s7 $s7 1
	subu	$t6 $t6 $s7
	
	j	d_while_grid_is_within_grid
	
d_next_row:

	addi	$s6 $s6 1

	addu	$t5 $t5 $t6
	addi	$s7 $s7 1
	subu	$t6 $t6 $s7
	
	j 	d_while_grid_is_within_grid




exit:						#program termination			

	li      $v0, 10
    	syscall   
    	
no_words_found_output:				#print -1

	li      $v0, 1
	li      $a0, -1
    	syscall   
    	
    	j exit
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
