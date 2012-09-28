all: clean test

test: unsse
	curl -N -s -S http://localhost:9999/abc | ./unsse

unsse: unsse.c
	gcc -o $@ $< -lfl

unsse.c: unsse.fl
	# flex -7 -o $@ unsse.fl
	flex -I -o $@ unsse.fl

clean: 
	rm -f unsse.c unsse
