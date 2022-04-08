.PHONY: clean, mrproper
CC = clang
LIBS= -framework AppKit -framework Foundation -framework Carbon
CFLAGS = -g -Wall

all: keyboard-watcher

run: keyboard-watcher
	./$<

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<

keyboard-watcher: main.o KWController.o KWKeyboardTap.o KWKeystroke.o KWKeystrokeTransformer.o
	$(CC) $(LIBS) $(CFLAGS) -o $@ $+

clean:
	rm -f *.o

mrproper: clean
	rm -f keyboard-watch
