# Ink Popochiu Bridge

A [Godot Engine](https://godotengine.org/) plugin that supports playing [Ink](https://www.inklestudios.com/ink/) scripts in adventure games made with [Popochiu](https://carenalga.itch.io/popochiu).

This is inspired by Graham Hayes' [AC-Ink-Integration](https://github.com/Graham-Hayes/AC-Ink-Integration) and Deep Entertainment's [Escoria Ink Bridge](https://github.com/deep-entertainment/escoria-ink-bridge).

## Requirements

+ [Godot 3.5](https://godotengine.org/)
+ [inkGD 0.5.0](https://github.com/ephread/inkgd)
+ [Popochiu 1.9](https://github.com/mapedorr/popochiu)
+ [Ink 1.1.1](https://github.com/inkle/ink)

## Writing Dialog

When writing scripts in Ink, start the line with the character speaking and a colon:

```
Player: Hi there, let's test this out!
```

## TODO

This plugin is a work in progress.

+ Check for objects in the player's inventory
+ Add and remove objects from the player's inventory
+ Play animations from Ink scripts
+ Specify the ink script name in the configuration.
+ Remember whether a node was visited in game; don't require variables for each node.