all: clean pub test

pub: pub.c sse-tools.c http.c
	gcc -o $@ $^ -lcurl -Wall

test: sse-client dog
	echo run | gdb sse-client --args sse-client http://localhost:4567/sub/chat ./dog
	# ./sse-client http://localhost:4567/sub/chat ./dog

sse-client: sse-client.c sse-tools.c http.c
	gcc -o $@ $^ -lcurl -Wall

sse-client.c: sse-client.fl
	flex -I -o $@ $<

dog: dog.c
	gcc -o $@ $< -Wall

clean: 
	rm -f sse-client sse-client.c pub dog

