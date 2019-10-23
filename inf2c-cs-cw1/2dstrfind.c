/***********************************************************************
* File       : <2dstrfind.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid

// Inf2C-CS Coursework 1. Task 3-5
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////

// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
int contain(char *string, char *word)
{
  while (1) {
    if (*string != *word){
      return (*word == '\n');
    }
    if (*string == '\n' && *word == '\n'){ //last char for word and char
      return (*word == '\n');
    }

    string++;
    word++;
  }

  return 0;
}

// this functions finds the first match in the grid
void strfind()
{

  char *c = dictionary + dictionary_idx[0];

  while(*c != '\0'){
    if(*c == '\n'){
      dict_num_words++;
    }
    c++;
  }

  //****************//
  //Horizontal Search//
  //*****************//

  int idx = 0;
  int grid_idx = 0;
  char *word;
  int word_found = 0;
  int row = 1;
  int grid_clm = 0;
  int max_grid_length = 0; //max length of each row

  while (grid[grid_idx] != '\0')
  {

    word = dictionary + dictionary_idx[0];
    char *grid_char = &grid[grid_idx];

    // store to update max_grid_length
    if(grid[grid_idx] == '\n'){
      row++;
      max_grid_length = grid_clm+1;
      grid_clm = 0;
      grid_idx++;
      continue;
    }

    while(*word != '\n')
    {
      int match_clm = grid_idx; // back to start point grid - using this to compare potential match
      char *match_word = word; // back to start point dict - using this to compare potential match

      grid_char = &grid[grid_idx];

      while(*match_word == *grid_char)
      {

        match_clm++;
        match_word++;

        if (*match_word == '\n' || *match_word == '\0')
        {
          match_word = word;

          print_int(row-1);
          print_char(',');
          print_int(grid_clm);
          print_char(' ');
          print_char('H');
          print_char(' ');

          while(*match_word != '\n' && *match_word != '\0')
          {
            print_char(*match_word);
            match_word++;
          }
          print_char('\n');

          word_found = 1;

          continue;
        }

        if(match_clm == '\n')
        {
          break;
        }

        grid_char = &grid[match_clm];

      }

      while(*word != '\n' && *word != '\0'){
        word++;

      }
      if (*word == '\0'){
        break;
      }
      word++;
    }

    grid_idx++;
    grid_clm++;

    if(grid[grid_idx] == '\0'){
      max_grid_length = grid_clm+1;
    }
  }

  //***************//
  //vertical search//
  //***************//

  char *grid_char;
  char *match_word;

  word = dictionary + dictionary_idx[0];
  int max_grid_height = row; // max y (max_grid_height) on grid
  row = 0;
  grid_clm = 0;

  // print_char(grid[18]);

  while (grid[grid_clm] != '\n' && grid[grid_clm] != '\0')
  {
    row = 0;

    while(row < max_grid_height)
    {
      word = dictionary + dictionary_idx[0]; //first char from dictionary ***

      while(*word != '\0')
      {

        int match_row = row; // back to start point grid - using this to compare potential match
        match_word = word; // back to start point dict - using this to compare potential match

        grid_char = &grid[grid_clm + max_grid_length*match_row];

        while(*match_word == *grid_char)
        {

          match_row++;
          match_word++;

          if (*match_word == '\n' || *match_word == '\0')
          {
            match_word = word;

            print_int(row);
            print_char(',');
            print_int(grid_clm);
            print_char(' ');
            print_char('V');
            print_char(' ');

            while(*match_word != '\n' && *match_word != '\0')
            {
              print_char(*match_word);
              match_word++;
            }
            print_char('\n');

            word_found = 1;

            continue;
          }
          if(match_row >= max_grid_height)
          {
            break;
          }

          grid_char = &grid[grid_clm + max_grid_length*match_row];
        }

        // next dictionary word
        while(*word != '\n' && *word != '\0'){
          word++;

        }
        if (*word == '\0'){
          break;
        }
        word++;

      }
      row++; //next grid row
    }
    grid_clm++; //next grid column
  }

  //****************//
  //diagnonal search//
  //****************//

  word = dictionary + dictionary_idx[0];
  max_grid_height = row; // max y (max_grid_height) on grid
  int d_row = 0; //row start point
  int grid_init = 0; //diagnonal search start point
  int grid_init_row = 0; // keeping track of the grid_intit row

  while (grid_init < max_grid_height*max_grid_length)
  {
    d_row = 0;

    while(d_row < max_grid_height && ((d_row + grid_init < max_grid_length - 1 && grid_init_row == 0) || grid_init_row > 0))
    {
      word = dictionary + dictionary_idx[0]; //first char from dictionary ***

      while(*word != '\0')
      {

        int match_d_row = d_row; // back to start point grid - using this to compare potential match

        if(grid_init_row == 0){
          match_d_row = d_row - grid_init_row;
        }

        match_word = word; // back to start point dict - using this to compare potential match

        grid_char = &grid[grid_init + (max_grid_length + 1)*match_d_row];

        while(*match_word == *grid_char)
        {

          match_d_row++;
          match_word++;

          if (*match_word == '\n' || *match_word == '\0')
          {
            match_word = word;

            print_int(d_row+grid_init_row);
            print_char(',');
            if(grid_init >= max_grid_length -1){
              print_int(d_row);
            }
            else{
              print_int(grid_init+d_row);
            }
            print_char(' ');
            print_char('D');
            print_char(' ');

            while(*match_word != '\n' && *match_word != '\0')
            {
              print_char(*match_word);
              match_word++;
            }
            print_char('\n');

            word_found = 1;

            continue;
          }

          if(match_d_row >= max_grid_height || (grid_init + match_d_row >= max_grid_length && grid_init_row == 0))
          {
            break;
          }

          grid_char = &grid[grid_init + max_grid_length*match_d_row + match_d_row];
        }
        // next dictionary word
        while(*word != '\n' && *word != '\0'){
          word++;

        }
        if (*word == '\0'){
          break;
        }
        word++;
      }
      d_row++; //next grid row
    }

    //next grid init position
    if(grid_init <= max_grid_length-1)
    {
      grid_init++;

      if(grid_init == max_grid_length-1) // grid_init = \n
      {
        grid_init++;
        grid_init_row++;
        max_grid_height = max_grid_height - grid_init_row;
        continue;
      }
    }
    else
    {
      grid_init += max_grid_length;
      grid_init_row++;
      max_grid_height = max_grid_height - grid_init_row;
    }

  }


  if (word_found == 0){
    print_string("-1\n");
  }

  return;
}



//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////


  strfind();

  return 0;
}
