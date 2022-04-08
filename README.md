# keyboard-watcher

Extract code of the core logic from KeyCastr, which is also the epitome of the whole MVC code. That's to say, I just need the model and controller.

## Build and run

```
make
make run
```

It's required to use `sudo` to enable the creation of event tap for observing `Keydown` event in macOS.

BTW, I'm still trying to figure out why put the executable file in `Accessibility` and `Input Monitoring` doesn't grant the access to create `KeyDown` event tap.

## How it works?

```
.
├── KWController.h
├── KWController.m
├── KWKeyboardTap.h
├── KWKeyboardTap.m
├── KWKeystroke.h
├── KWKeystroke.m
├── KWKeystrokeTransformer.h
├── KWKeystrokeTransformer.m
├── Makefile
├── README.md
├── main.m
└── utils.h
```

- `KWController` is the controller that implements the delegation defined in `KWKeyboardTap`. I use it directly in `main.m` as the entry point of the core logic as there is no GUI code involved.
- `KWKeyboardTap` is the model holds the logic on how to deal with run loop, register the source and release the source.
- `KWKeyStroke` is the model holds the information the program needs from a keystroke event.
- `KWKeystrokeTransformer` is used for converting KeyCode into human-friendly format.
