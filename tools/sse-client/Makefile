all: clean test

test: sse-client dog
	./sse-client http://localhost:4567/sub/chat ./dog

sse-client: sse-client.c
	gcc -o $@ $< -Wall

sse-client.c: sse-client.fl
	flex -I -o $@ $<

dog: dog.c
	gcc -o $@ $< -Wall

clean: 
	rm -f sse-client dog

