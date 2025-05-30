@tool
extends InkPopochiuProp


# Override to specify custom interactions with items on this character
func _on_item_used(_item: PopochiuInventoryItem) -> void:
	if C.player.can_move:
		C.player.can_move = false
		await on_default_item()
		C.player.can_move = true
