#include "sse-tools.h"

#include <curl/curl.h>

void curl_perform(CURL* curl) {
  CURLcode res = curl_easy_perform(curl);
  if(res != CURLE_OK) die(curl_easy_strerror(res));
}

CURL* curl_handle(const char* url) {
  static int curl_initialised = 0;
  if(!curl_initialised) {
    curl_initialised = 1;
    curl_global_init(CURL_GLOBAL_ALL);  /* In windows, this will init the winsock stuff */ 
    atexit(curl_global_cleanup);
  }

  CURL *curl = curl_easy_init();
  if(!curl)
    die("curl");
  
  /* === set defaults ============================================== */
  curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1); // no progress bar
  curl_easy_setopt(curl, CURLOPT_USERAGENT, USERAGENT);
  
#ifdef SKIP_PEER_VERIFICATION
  /*
   * If you want to connect to a site who isn't using a certificate 
   * that is signed by one of the certs in the CA bundle you have, you
   * can skip the verification of the server's certificate. This makes 
   * the connection A LOT LESS SECURE.
   *
   * If you have a CA cert for the server stored someplace else than 
   * in the default bundle, then the CURLOPT_CAPATH option might come 
   * handy for you.
   */ 
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
#endif

#ifdef SKIP_HOSTNAME_VERIFICATION
  /*
   * If the site you're connecting to uses a different host name that 
   * what they have mentioned in their server certificate's commonName
   * (or subjectAltName) fields, libcurl will refuse to connect. You can 
   * skip this check, but this will make the connection less secure.
   */ 
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
#endif

  /* set URL */
  
  curl_easy_setopt(curl, CURLOPT_URL, url);
  
  return curl;
}

void connect_to_url(const char* url, 
        size_t(*on_data)(char *ptr, size_t size, size_t nmemb, void *userdata))
{
  CURL *curl = curl_handle(url);

  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, on_data);

  curl_perform(curl);         /* Perform the request */ 

  curl_easy_cleanup(curl);    /* cleanup */
}
