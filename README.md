# Ink Popochiu Bridge

A [Godot Engine](https://godotengine.org/) plugin that supports playing [Ink](https://www.inklestudios.com/ink/) scripts in adventure games made with [Popochiu](https://carenalga.itch.io/popochiu).

This is inspired by Graham Hayes' [AC-Ink-Integration](https://github.com/Graham-Hayes/AC-Ink-Integration) and Deep Entertainment's [Escoria Ink Bridge](https://github.com/deep-entertainment/escoria-ink-bridge).

## Requirements

+ [Godot 4.5](https://godotengine.org/)
+ [inkGD](https://github.com/ephread/inkgd)
+ [Popochiu 2](https://github.com/mapedorr/popochiu)
+ [Ink](https://github.com/inkle/ink)

## Writing Dialog

When writing scripts in Ink, start the line with the character speaking and a colon:

```
Player: Hi there, let's test this out!
```

Text without a character name will be spoken by the narrator (using G.show_system_text).


