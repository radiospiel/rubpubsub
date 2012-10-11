#include "sse-tools.h"
#include <curl/curl.h>

#define HELP "pub writes an event to rubpubsub server\n\n" \
  "  sse-client [ -i <id> ] URL [ <data> ]\n\n"

static void help() {
  fprintf(stderr, "pub, compiled %s %s.\n\n", __DATE__, __TIME__);
  fprintf(stderr, "%s\n", HELP);

  exit(1);
}

int main(int argc, char** argv) 
{
  char *url = NULL, *id = NULL, *data = NULL;

  /* === parse arguments =========================================== */

  opterr = 0;

  int flag;
  while ((flag = getopt(argc, argv, "i:")) != -1) {
    switch (flag)
    {
      case 'i':
        id = optarg;
        break;
      default:
        help();
    }
  }
  
  argv += optind-1;
  argc -= optind-1;
  
  if(*++argv) url = *argv;
  if(*++argv) data = *argv;

  if(!url) help();

  /* === read data from stdin, if needed =========================== */
  
  unsigned dataLength = 0;
  if(data)
    dataLength = strlen(data);
  else {
    /*
     * If the event data is not passed in from the command line we
     * read it from stdin.
     * 
     * TODO: set up a libcurl callback instead of reading here;
     * see http://curl.haxx.se/libcurl/c/post-callback.html
     */
    /*
     * Note: we are leaking data in this branch (but not in the other), 
     * but we exit this process as soon as we no longer need this 
     * data anymore.
     */
    dataLength = read_all(FD_READ, &data);
    if(dataLength <= 0)
      die("read");
  } 
  
  /* === send request to server ==================================== */

  // fprintf(stderr, id = %s\n", id);
  // fprintf(stderr, "url = %s\n", url);
  // fprintf(stderr, "%s\n", data);
  
  /* get a curl handle */
  CURL *curl = curl_handle(url);

  curl_easy_setopt(curl, CURLOPT_POST, 1L);                         /* set POST */ 
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);                 /* set POST data */
  curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, dataLength);

  curl_perform(curl);
  
  curl_easy_cleanup(curl);
  
  return 0;
}
