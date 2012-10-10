/*
 * dog is not cat
 */
#include <stdio.h>

int main(int argc, const char** argv) 
{
  while(*++argv)
    puts(*argv);

  int ch;
  while(EOF != (ch = getchar()))
    putchar(ch);
    
  return 0;
}
