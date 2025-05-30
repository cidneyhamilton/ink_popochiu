@tool
class_name InkPopochiuCharacter
extends PopochiuCharacter

#region Virtual ####################################################################################
# When the room in which this node is located finishes being added to the tree
func _on_room_set() -> void:
	pass

# When the node is clicked
func _on_click() -> void:
	print("Clicking...")
	if C.player.can_move:
		C.player.can_move = false
		await on_interact()
		C.player.can_move = true

func _on_double_click() -> void:
	print("Double clicking")
	await _on_click()

# When the node is right clicked
func _on_right_click() -> void:
	print("Right clicking")
	await _on_click()

# When the node is middle clicked
func _on_middle_click() -> void:
	print("Middle clicking")
	await _on_click()

# When the node is clicked and there is an inventory item selected
func _on_item_used(_item: PopochiuInventoryItem) -> void:
	print("Using item")
	if C.player.can_move:
		C.player.can_move = false
		await on_default_item()
		C.player.can_move = true
		
# Use it to play the idle animation for the character
func _play_idle() -> void:
	super()


# Use it to play the walk animation for the character
# target_pos can be used to know the movement direction
func _play_walk(target_pos: Vector2) -> void:
	super(target_pos)


# Use it to play the talk animation for the character
func _play_talk() -> void:
	super()


# Use it to play the grab animation for the character
func _play_grab() -> void:
	super()


# Called when the character stops moving
func _on_move_ended() -> void:
	pass


#endregion

#region Public #####################################################################################

# Default single-click activity
func on_interact() -> void:
	await C.player.walk_to_clicked_blocking()
	await C.player.face_clicked()
	var node_name = "%s" % script_name
	print("Playing node %s" % node_name)
	await Bridge.play(node_name)

# Unhandled items
func on_default_item() -> void:
	await G.show_system_text("There's no reason for you to do that.")

#endregion
