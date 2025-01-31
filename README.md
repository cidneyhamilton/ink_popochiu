# Ink Popochiu Bridge

A [Godot Engine](https://godotengine.org/) plugin that supports playing [Ink](https://www.inklestudios.com/ink/) scripts in adventure games made with [Popochiu](https://carenalga.itch.io/popochiu).

This is inspired by Graham Hayes' [AC-Ink-Integration](https://github.com/Graham-Hayes/AC-Ink-Integration) and Deep Entertainment's [Escoria Ink Bridge](https://github.com/deep-entertainment/escoria-ink-bridge).

## Requirements

+ [Godot 4.3](https://godotengine.org/)
+ [inkGD](https://github.com/ephread/inkgd)
+ [Popochiu 2](https://github.com/mapedorr/popochiu)
+ [In](https://github.com/inkle/ink)

## Writing Dialog

When writing scripts in Ink, start the line with the character speaking and a colon:

```
Player: Hi there, let's test this out!
```

## Popochiu Commands Supported

C.walk_to_marker
C.teleport_to_marker
C.face_up
C.face_down
C.fade_left
C.face_right
A.play_sfx
I.add_item
I.remove_item


## TODO

This plugin is a work in progress.

+ Check for objects in the player's inventory
+ Better configuration
+ Specify the ink script name in the configuration.
