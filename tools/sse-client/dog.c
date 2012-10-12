/*
 * dog is not cat
 */
#include <stdio.h>

int main(int argc, const char** argv) 
{
  const char *event = NULL, *id = NULL;
  if(*++argv) event = *argv;
  if(*++argv) id = *argv;
  
  if(event) printf("%s#", event);
  if(id) printf("%s> ", id);
    
  int ch;
  while(EOF != (ch = getchar()))
    putchar(ch);
  
  putchar('\n');
  
  return 0;
}
