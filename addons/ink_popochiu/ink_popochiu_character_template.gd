@tool
extends InkPopochiuCharacter

const Data := preload('res://addons/popochiu/engine/templates/character_state_template.gd')

var state: Data = null

# Override to specify custom interactions with items on this character
func _on_item_used(_item: PopochiuInventoryItem) -> void:
	if C.player.can_move:
		C.player.can_move = false
		await on_default_item()
		C.player.can_move = true
