all: clean test

test: unsse
	./unsse

unsse: unsse.c
	gcc -o $@ $< -Wall

unsse.c: unsse.fl
	flex -I -o $@ unsse.fl

clean: 
	rm -f unsse.c unsse
