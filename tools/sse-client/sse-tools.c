#include "sse-tools.h"

char** command = NULL;
unsigned command_ofs = 0;

#define READ 0
#define WRITE 1

void onEvent(const char* event, const char* id, const char* data)
{
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
    close(fd[WRITE]);
    dup2(fd[READ], READ);

    execvp(command[0], command);
    _die(command[0]);  /* die via _exit: a failed child should not flush parent files */
  }
  else { /* code for parent */ 
    close(fd[READ]);

    write_all(fd[WRITE], data, strlen(data));
    write_all(fd[WRITE], "\n", 1);
    close(fd[WRITE]);
    
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
int write_all(int fd, const void* data, unsigned dataLen) {
  int len = 0;
  while(len < dataLen) {
    int written = write(fd, data, dataLen);
    if(written < 0)
      return -1;

    data += written;
    dataLen -= written;
    len += written;
  }

  return len;
}


void die(const char* msg) {
  perror(msg); 
  exit(1);
}

void _die(const char* msg) {
  perror(msg); 
  _exit(1);
}
