#ifndef SSE_TOOLS_H
#define SSE_TOOLS_H

#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>

/* 
 * The \a command and \a command_ofs variables hold the command to
 * execute on each received event. 
 */
extern char** command;
extern unsigned command_ofs;

/*
 * The \a onEvent function builds the
 * final command to run from the values in \a command and \a command_ofs
 * and its \a event and \a id parameters; i.e. when you run sse-client
 * using
 *
 *   sse-client http://localhost:12567/abc process_events abc def
 *
 * the process_events command will be called with parameters
 *
 *   process_events abc def <event> <id>
 *
 * where <event> and <id> are the event attributes; 
 * and the data part will be written to process_events STDIN.
 */
extern void onEvent(const char* event, const char* id, const char* data);

/*
 * Write \a dataLen bytes from \a data to \a fd.
 */
extern int write_all(int fd, const void* data, unsigned dataLen);

/*
 * Write out an error message using perror(3) and exit 
 * the process via exit(3).
 */
extern void die(const char* msg);

/*
 * Write out an error message using perror(3) and exit 
 * the process via _exit(2).
 */
extern void _die(const char* msg);

#endif
