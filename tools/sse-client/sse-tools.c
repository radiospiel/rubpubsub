#include "sse-tools.h"

char** command = NULL;
unsigned command_ofs = 0;

void on_event(const char* event, const char* id, const char* data)
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


void die(const char* msg) {
  perror(msg); 
  exit(1);
}

void _die(const char* msg) {
  perror(msg); 
  _exit(1);
}
