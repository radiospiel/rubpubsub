all: clean test

test: sse-client
	./sse-client http://localhost:4567/sub/chat echo

sse-client: unsse.c
	gcc -o $@ $< -Wall

unsse.c: unsse.fl
	flex -I -o $@ unsse.fl

clean: 
	rm -f unsse.c unsse
