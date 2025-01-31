@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton(
		"InkPopochiu",
		"res://addons/ink_popochiu/InkPopochiu.gd"
	)

func _exit_tree():
	remove_autoload_singleton("InkPopochiu")
