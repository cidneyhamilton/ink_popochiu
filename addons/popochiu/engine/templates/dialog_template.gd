@tool
extends PopochiuDialog


#region Virtual ####################################################################################
func _on_start() -> void:
	# One can put here something to execute before showing the dialog options.
	# E.g. Make the PC to look at the character which it will talk to, walk to
	# it, and say something (or make the character say something):
#	await C.player.face_clicked()
#	await C.player.say("Hi")
#	await C.Popsy.say("Oh! Hi...")
	# (!) It MUST always use an await
	await PopochiuUtils.e.get_tree().process_frame


func _option_selected(opt: PopochiuDialogOption) -> void:
	# You can make the player character say the selected option with:
#	await D.say_selected()
	
	# Use match to check which option was selected and execute something for
	# each one
	match opt.id:
		_:
			# By default close the dialog. Options won't show after calling
			# stop()
			stop()
	
	_show_options()


# Use this to save custom data for this PopochiuDialog when saving the game.
# The Dictionary must contain only JSON supported types: bool, int, float, String.
func _on_save() -> Dictionary:
	return {}


# Called when the game is loaded.
# This Dictionary should has the same structure you defined for the returned one in _on_save().
func _on_load(data: Dictionary) -> void:
	prints(data)


#endregion
