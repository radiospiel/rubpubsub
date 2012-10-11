#include "sse-tools.h"

char** command = NULL;
unsigned command_ofs = 0;

void on_event(const char* event, const char* id, const char* data)
{
  // fprintf(stderr, "on_event %s#%s: '%s'\n", event, id, data);
  
  // prepare command.
  command[command_ofs] = (char*)event;
  command[command_ofs+1] = (char*)id;

  // Prepare pipe for subprocess
  int fd[2];
  if (pipe(fd) != 0) die("pipe");
  
  // Start subprocess
  pid_t pid = fork();
  if (pid == -1) die("fork");
  
  if (pid == 0) { /* the child */
    close(fd[FD_WRITE]);
    dup2(fd[FD_READ], FD_READ);

    execvp(command[0], command);
    _die(command[0]);  /* die via _exit: a failed child should not flush parent files */
  }
  else { /* code for parent */ 
    close(fd[FD_READ]);

    write_all(fd[FD_WRITE], data, strlen(data));
    close(fd[FD_WRITE]);
    
    int status = 0;
    waitpid(pid, &status, 0);
    
    // Show results if something broke.
    if(WIFEXITED(status) && WEXITSTATUS(status) != 0)
      fprintf(stderr, "child exited with stats %d\n", WEXITSTATUS(status));
    else if(WIFSIGNALED(status))
      fprintf(stderr, "child exited of signal %d\n", WTERMSIG(status));
  }
}

/*
 * write dataLen bytes from data to the fd handle.
 */
int write_all(int fd, const char* data, unsigned dataLen) {
  const char *s = data, *e = data + dataLen;
  
  while(data < e) {
    int written = write(fd, data, e - data);
    if(written < 0)
      return -1;

    data += written;
  }

  return e - s;
}

/*
 * read data from fd handle, return a malloced area in the pResult 
 * buffer - this must be freed by the caller - and returns the number
 * of bytes read.
 */
int read_all(int fd, char** pResult) {
  char* buf[8192]; 
  int length = 0;
  
  *pResult = 0;
  
  while(1) {
    int bytes_read = read(fd, buf, sizeof(buf));

    if(bytes_read < 0)
      return -1;
    if(bytes_read == 0) 
      break;

    *pResult = realloc(*pResult, length + bytes_read + 1);
    
    memcpy(*pResult + length, buf, bytes_read);
    length += bytes_read;
  }

  if(*pResult) {
    (*pResult)[length] = 0;
  }
  return length;
}

void die(const char* msg) {
  perror(msg); 
  exit(1);
}

void _die(const char* msg) {
  perror(msg); 
  _exit(1);
}
