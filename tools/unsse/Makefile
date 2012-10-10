all: clean test

test: sse-client dog
	./sse-client http://localhost:4567/sub/chat ./dog

sse-client: unsse.c
	gcc -o $@ $< -Wall

unsse.c: unsse.fl
	flex -I -o $@ unsse.fl

dog: dog.c
	gcc -o $@ $< -Wall

clean: 
	rm -f unsse.c unsse
