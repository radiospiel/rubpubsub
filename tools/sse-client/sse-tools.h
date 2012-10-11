#ifndef SSE_TOOLS_H
#define SSE_TOOLS_H

#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>

#define FD_READ 0
#define FD_WRITE 1

/* 
 * The \a command and \a command_ofs variables hold the command to
 * execute on each received event. 
 */
extern char** command;
extern unsigned command_ofs;

/*
 * The \a on_event function builds the
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
extern void on_event(const char* event, const char* id, const char* data);

/*
 * Write \a dataLen bytes from \a data to \a fd.
 */
extern int write_all(int fd, const char* data, unsigned dataLen);

/*
 * read data from fd handle, return a malloced area in the pResult 
 * buffer - this must be freed by the caller - and returns the number
 * of bytes read.
 */
int read_all(int fd, char** pResult);

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

/*
 * connect to the SSE stream at \a url. Data received is reported via 
 * the on_data callback function.
 */
extern void connect_to_url(const char* url, 
size_t(*on_data)(char *ptr, size_t size, size_t nmemb, void *userdata));

#endif
