# Ink Popochiu Bridge

A [Godot Engine](https://godotengine.org/) plugin that supports playing [Ink](https://www.inklestudios.com/ink/) scripts in adventure games made with [Popochiu](https://carenalga.itch.io/popochiu).

This is inspired by Graham Hayes' [AC-Ink-Integration](https://github.com/Graham-Hayes/AC-Ink-Integration) and Deep Entertainment's [Escoria Ink Bridge](https://github.com/deep-entertainment/escoria-ink-bridge).

## Requirements

+ [Godot 4.3](https://godotengine.org/)
+ [inkGD](https://github.com/ephread/inkgd)
+ [Popochiu 2](https://github.com/mapedorr/popochiu)
+ [Ink](https://github.com/inkle/ink)

## Writing Dialog

When writing scripts in Ink, start the line with the character speaking and a colon:

```
Player: Hi there, let's test this out!
```

Text without a character name will be spoken by the narrator (using G.show_system_text).

## Templates

Use the provided templates instead of Popochiu's defaults to streamline creation of new props, rooms, characters, and hotspots to use the default interactions.

## Interaction Templates

Currently supports a single-click interface. 

## Popochiu Functions Supported

E.wait

PopochiuAudioCue.play
PopochiuAudioCue.stop

PopochiuCharacter.face_down
PopochiuCharacter.fade_left
PopochiuCharacter.face_right
PopochiuCharacter.face_up
PopochiuCharacter.hide
PopochiuCharacter.play_animation
PopochiuCharacter.state
PopochiuCharacter.walk_to_marker
PopochiuCharacter.teleport_to_marker

PopcohiuInventoryItem.add_item
PopochiuInventoryItem.remove_item

PopochiuProp.animate

PopochiuRoom.state

R.goto_room


