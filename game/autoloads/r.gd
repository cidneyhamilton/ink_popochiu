@tool
extends "res://addons/popochiu/engine/interfaces/i_room.gd"

# classes ----
const PR101 := preload("res://game/rooms/101/room_101.gd")
# ---- classes

# nodes ----
var R101: PR101 : get = get_101
# ---- nodes

# functions ----
func get_101() -> PR101: return get_runtime_room("101")
# ---- functions

