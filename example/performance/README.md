This directory contains a setup for a performance test. It uses foreman to start a server instance, and listeners and producers.

    foreman start -m "server=1,listener=2,sender=20"

Each sender produces ~50 messages per second.

To run against an external server, start this with

    URL=http://my_test_instance foreman start -m "server=0,listener=2,sender=20"
    
