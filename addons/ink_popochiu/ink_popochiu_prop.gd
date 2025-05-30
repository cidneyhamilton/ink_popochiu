@tool
class_name InkPopochiuProp
extends PopochiuProp

@onready var animation_player : AnimationPlayer = $AnimationPlayer

#region Virtual ####################################################################################
# When the node is clicked
func _on_click() -> void:
	if C.player.can_move:
		C.player.can_move = false	
		await on_interact()
		C.player.can_move = true

func _on_double_click() -> void:
	await _on_click()

func _on_right_click() -> void:
	await _on_click()
	
func _on_middle_click() -> void:
	await _on_click()
	
func _on_item_used(_item: PopochiuInventoryItem) -> void:
	if C.player.can_move:
		C.player.can_move = false
		await on_default_item()
		C.player.can_move = true
	
#endregion

#region Public #####################################################################################


# Default single-click activity
func on_interact() -> void:
	await C.player.walk_to_clicked_blocking()
	await C.player.face_clicked()
	var node_name = "%s.%s" % [R.current.script_name, script_name]
	await Bridge.play(node_name)

# Unhandled items
func on_default_item() -> void:
	await G.show_system_text("There's no reason for you to do that.")
		
#endregion
