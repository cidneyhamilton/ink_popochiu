@tool
extends "res://addons/popochiu/engine/interfaces/i_character.gd"

# classes ----
const PCPopsy := preload("res://game/characters/popsy/character_popsy.gd")
const PCGodiu := preload("res://game/characters/godiu/character_godiu.gd")
# ---- classes

# nodes ----
var Popsy: PCPopsy : get = get_Popsy
var Godiu: PCGodiu : get = get_Godiu
# ---- nodes

# functions ----
func get_Popsy() -> PCPopsy: return get_runtime_character("Popsy")
func get_Godiu() -> PCGodiu: return get_runtime_character("Godiu")
# ---- functions

