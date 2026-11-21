class_name InkPopochiu
extends Node

const REGEX_TEXT = "^(?<character>[\\w]+):\\s*(?<text>.+)"
const REGEX_COMMAND = ">>>\\s*(?<command>.+)"

const SAVE_GAME_PATH := "user://save_%d_ink.json"

var InkPlayerFactory = preload("res://addons/inkgd/ink_player_factory.gd") as GDScript

var _current_story : InkPlayer = InkPlayerFactory.create()
var _regex_text: RegEx = RegEx.new()
var _regex_command: RegEx = RegEx.new()

signal show_avatars_on_left
signal show_avatars_on_right

func _enter_tree() -> void:
	InkPopochiuConfig.init_settings()
	
func _ready() -> void:
	
	_current_story.loads_in_background = false
	
	add_child(_current_story)

	var ink_file_path : String = ProjectSettings.get_setting("ink_popochiu/story")
	_current_story.ink_file = load(ink_file_path)
	_current_story.create_story()

	_regex_text.compile(REGEX_TEXT)
	_regex_command.compile(REGEX_COMMAND)
	
	_connect_signals()

func _connect_signals():
	_current_story.connect("loaded", Callable(self, "_loaded"))

func _loaded(successfully: bool):
	if !successfully:
		print("Ink story not loaded!")
		return	

	# Store variables
	for variable in _current_story._story.variables_state.enumerate():
		if Globals.get(variable) != null:
			_current_story.observe_variable(variable, self, "_observe_variable")
			_current_story._story.variables_state.set_variable(variable, Globals.get(variable))
			# print("Binding variable %s to %s" % [variable, Globals.get(variable)])

	# Bind function
	_current_story.bind_external_function("print_current_room", self, "_print_current_room")

# Continues the story
func _continue_story() -> void: 
	if _current_story.can_continue:
		# print("Story can continue")
		var text: String = _current_story.continue_story()
		var text_info: RegExMatch = _regex_text.search(text)
		var command_info: RegExMatch = _regex_command.search(text)
		if command_info:
			await _run_command(command_info.get_string("command"))
			await _continue_story()
		elif text_info:
			var speaker = text_info.get_string("character")
			var dialog_line = text_info.get_string("text")
			if len(dialog_line) > 0:
				await _say(speaker, dialog_line)
			else:
				_continue_story()
		elif text != "":
			await G.show_system_text(text)
			# print("Narrator: %s" % text)
			await _continue_story()
		else:
			print("Text doesn't match form <character name>:<text>: %s" % text)
			await _continue_story()
	elif _current_story.current_choices.size() > 0:
		await _choose()


# Runs a given command from ink
func _run_command(command: String) -> void:
	# print("Attempting to run command: %s" % command)
	var command_arr = command.split(": ")
	var command_name = command_arr[0]
	var command_args = []
	if command_arr.size() > 1:
		command_args = command_arr[1].split(", ")
	await _run_command_with_args(command_name, command_args)

# Virtual: can be overridden with custom commands. These are Popochiu's default.
func _run_command_with_args(command_name: String, command_args: Array) -> void:
	match command_name:
		"ADD_ITEM":
			var item_name : String = command_args[0]
			await _add_item(item_name)
			# Hide prop in room
			if R.current.get_prop(item_name) != null:
				R.current.get_prop(item_name).hide()
		"ANIMATE_CHARACTER":
			var char_name : String = command_args[0]
			var animation_name : String = command_args[1]
			await _animate_character(char_name, animation_name)
		"ANIMATE_PROP":
			var prop_name : String = command_args[0]
			var animation_name: String = command_args[1]
			await _animate_prop(prop_name, animation_name)
		"AUTOSAVE":
			E.save_game(1, "Autosave")
		"CHARACTER_HIDE":
			var char_name = command_args[0]
			C.get_character(char_name).hide()
		"CHARACTER_SHOW":			
			var char_name = command_args[0]
			C.get_character(char_name).show()
			print("Showing character")
		"CHARACTER_TOP_LEVEL":
			var char_name = command_args[0]
			C.get_character(char_name).top_level = command_args[1] == "true"
			C.get_character(char_name).always_on_top = command_args[1] == "true"
		"CLIMB":
			var char_name = command_args[0]
			var destination = command_args[1]
			await C.get_character(char_name).climb(destination)
		"CLOSE_INVENTORY":
			PopochiuUtils.i.inventory_hide_requested.emit()
		"FACE_CLICKED":
			if PopochiuUtils.e.clicked != null:
				await C.player.face_clicked()
		"FACE_DOWN":
			var char_name = command_args[0]
			await C.get_character(char_name).face_down()
		"FACE_LEFT":			
			var char_name = command_args[0]
			await C.get_character(char_name).face_left()
		"FACE_RIGHT":
			var char_name = command_args[0]
			await C.get_character(char_name).face_right()
		"FACE_UP":			
			var char_name = command_args[0]
			await C.get_character(char_name).face_up()
		"FADE_MUSIC":
			var mx_name = command_args[0]
			var fade_duration = float(command_args[1])
			var from = float(command_args[2])
			var to = float(command_args[3])
			await _fade_mx(mx_name, fade_duration, from, to)
		"FOLLOW_CHARACTER":
			var char_name = command_args[0]
			var char_to_follow_name = command_args[1]
			C.get_character(char_name).follow_character = char_to_follow_name
			C.get_character(char_name).start_following_character()
			print("%s is now following %s" % [char_name, char_to_follow_name])
		"GAME_OVER":
			# End the game
			await G.show_system_text("THE END")
			R.goto_room("Start", true)			
		"GOTO_ROOM":
			var room = command_args[0]
			var use_transition = true
			if command_args.size() > 1:
				use_transition = command_args[1] == "true"
			# Make sure the player can move during the transition
			C.player.can_move = true
			_goto_room(room, use_transition)
		"HIDE_PROP":
			var prop_name = command_args[0]
			var prop = R.get_prop(prop_name)
			if prop == null:
				print("No prop named %s found" % prop_name)
			else:
				prop.hide()
		"IGNORE_WALKABLE_AREAS":
			C.player.ignore_walkable_areas = command_args[0] == 'true'
		"MOVE_TO":
			var prop_name = command_args[0]
			var marker_name = command_args[1]
			var prop = R.get_prop(prop_name)
			var marker_position = R.get_marker_position(marker_name)
			await prop.move_to(marker_position)
		"PLAY_MUSIC":
			var mx_name = command_args[0]
			var fade_duration = 0.0
			var music_position = 0.0
			if len(command_args) > 1:
				fade_duration = float(command_args[1])
			if len(command_args) > 2:
				music_position = float(command_args[2])

			await _play_mx(mx_name, fade_duration, music_position)
		"PLAY_SFX":
			var sfx_name = command_args[0]
			print("Playing sfx: %s " % sfx_name)
			await _play_sfx(sfx_name)
		"REMOVE_ITEM":
			var item_name : String = command_args[0]
			_remove_item(item_name)
		"SET_CHARACTER_FLAG":
			if len(command_args) < 3:
				print("SET_CHARACTER_FLAG needs 3 command args: Character, state variable, and value")
			else:
				var char_name: String = command_args[0]
				var state_var: String = command_args[1]
				var state_val: bool = command_args[2] == "true" 
				await _set_character_state(char_name, state_var, state_val)
		"SET_ITEM_FLAG":
			if len(command_args) < 3:
				print("SET_ITEM_FLAG needs 3 command args: Inventory item, state variable, and value")
			else:
				var item_name : String = command_args[0]
				var state_var: String = command_args[1]
				var state_val: bool = command_args[2] == "true"
				await _set_item_state(item_name, state_var, state_val)
		"SET_ROOM_FLAG":
			if len(command_args) < 3:
				print("SET_ROOM_FLAG needs 3 command args: Room, state variable, and value")
			else:
				var room_name: String = command_args[0]
				var state_var: String = command_args[1]
				var state_val: bool = command_args[2] == "true" 
				await _set_room_state(room_name, state_var, state_val)
		"SHOW_AVATARS_ON_LEFT":
			show_avatars_on_left.emit()
		"SHOW_AVATARS_ON_RIGHT":
			show_avatars_on_right.emit()
		"SHOW_PROP":
			var prop_name = command_args[0]
			var prop = R.get_prop(prop_name)
			if prop == null:
				print("No prop named %s found" % prop_name)
			else:
				prop.show()
		"STOP_MUSIC":
			var mx_name = command_args[0]
			var fade_duration = 0.0
			if len(command_args) > 1:
				fade_duration = float(command_args[1])
				
			if mx_name in A and A[mx_name].is_playing():
				A[mx_name].stop(fade_duration)
		"STOP_SFX":
			var sfx_name = command_args[0]
			var fade_duration = 0.0
			if len(command_args) > 1:
				fade_duration = float(command_args[1])
			await _stop_sfx(sfx_name, fade_duration)
		"TELEPORT_TO_MARKER":			
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).teleport_to_marker(marker_name)
		"TOP_LEVEL":
			var prop_name = command_args[0]
			R.get_prop(prop_name).top_level = command_args[1] == "true"
			R.get_prop(prop_name).always_on_top = command_args[1] == "true"
		"UNFOLLOW":
			var char_name = command_args[0]
			C.get_character(char_name).stop_following_character()
		"WAIT":
			var duration : float = float(command_args[0])
			await _wait(duration)
		"WALK_TO_CLICKED":
			if PopochiuUtils.e.clicked != null:
				await C.player.walk_to_clicked_blocking()
		"WALK_TO_MARKER":
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).walk_to_marker(marker_name)
			# print("Reached marker %s " % marker_name)			
		"WALK_TO_MARKER_ASYNC":
			var char_name = command_args[0]
			var marker_name = command_args[1]
			C.get_character(char_name).walk_to_marker(marker_name)
		"WEAR_CLOTHING":
			var item_name = command_args[0]
			C.Sarah.wear(item_name)
		_:
			print("Command %s not found" % command_name)


# Allow player to choose a dialog option
func _choose() -> void:
	var opts = []
	for choice in _current_story.current_choices:
		# Only show debug options if this is a debug build
		if choice.text.begins_with("DEBUG: "):
			if OS.is_debug_build():
				opts.push_back(choice.text)
		else:
			opts.push_back(choice.text)

	var selection : PopochiuDialogOption = await D.show_inline_dialog(opts)
	
	await _choose_option(selection)


# Choose the given dialog option and continue the story
func _choose_option(opt: PopochiuDialogOption) -> void:
	var i := 0
	for choice in _current_story.current_choices:
		if choice.text == opt.text:
			_current_story.choose_choice_index(i)
			# Don't allow dialog to repeat itself
			_current_story.continue_story()
		i += 1
	await _continue_story()


# Say a line of text and continue the story
func _say(character: String, text: String) -> void:
	if C.get_character(character) == null:
		print("Character named %s not found! Cannot speak line of dialogue." % character)
	else:
		await C.get_character(character).say(text)
	await _continue_story()


# Update Popochiu's globals whenever a variable in ink changes
func _observe_variable(variable_name: String, value) -> void:
	# print("Variable %s updated from ink to %s" % [variable_name, value])
	Globals.set(variable_name, value)

func _bind_functions(function_list: Array) -> void:
	for function_name in function_list:
		_current_story.bind_external_function(function_name, self, "_%s" % function_name, false)

func _teleport_to_marker(char_name: String, marker_name: String) -> void:
	C.get_character(char_name).teleport_to_marker(marker_name)
	
func _walk_to_marker(char_name: String, marker_name: String) -> void:
	await C.get_character(char_name).walk_to_marker(marker_name)

func _set_character_state(char_name: String, state_key: String, state_val: bool) -> void:
	C.get_character(char_name).state[state_key] = state_val

func _set_item_state(item_name: String, state_key: String, state_val: bool) -> void:
	I.get_item_instance(item_name).state.set(state_key, state_val)
				
func _set_room_state(room_name: String, state_key: String, state_val: bool) -> void:
	R.get_runtime_room(room_name).state[state_key] = state_val
	
func _animate_character(char_name: String, anim_name: String) -> void:
	# print("Changing %s anim to %s" % [char_name, anim_name])
	await C.get_character(char_name).play_animation(anim_name)

func _animate_prop(prop_name: String, anim_name: String) -> void:
	var prop = R.get_prop(prop_name)
	if prop != null:
		await prop.animate(anim_name)
	else:
		print("Error: No prop with name %s found, can't animate it." % prop_name)
	
func _face_up(char_name: String) -> void:
	await C.get_character(char_name).face_up()

func _face_down(char_name: String) -> void:
	await C.get_character(char_name).face_down()

func _face_left(char_name: String) -> void:
	await C.get_character(char_name).face_left()

func _face_right(char_name: String) -> void:
	await C.get_character(char_name).face_right()

func _play_sfx(sfx_name: String) -> void:
	if sfx_name in A:
		A[sfx_name].play()
	else:
		print("Trying to play missing sound effect: %s" % sfx_name)

func _play_mx(mx_name: String, fade_duration: float, music_position: float) -> void:
	if mx_name in A:
		A[mx_name].play(fade_duration, music_position)
	else:
		print("Trying to play missing music track: %s" % mx_name)

func _fade_mx(mx_name: String, fade_duration: float, from: float, to: float) -> void:
	if mx_name in A:
		A[mx_name].fade(fade_duration, false, from, to)
	else:
		print("Trying to play missing music track: %s" % mx_name)
	
func _stop_sfx(sfx_name: String, duration: float = 0.0) -> void:
	if sfx_name in A:
		A[sfx_name].stop(duration)
	else:
		print("Trying to stop missing sound effect: %s" % sfx_name)
	
func _add_item(item_name: String, show_animation: bool = false) -> void:
	var item = I.get_item_instance(item_name)
	if item == null:
		print("Trying to add missing item named %s" % item_name)
	else:
		I.get_item_instance(item_name).add()

func _remove_item(item_name: String, show_animation: bool = false) -> void:
	var item = I.get_item_instance(item_name)
	if item == null:
		print("Trying to remove missing item named %s" % item_name)
	else:
		I.get_item_instance(item_name).remove()

func _wait(duration: float) -> void:
	await E.wait(duration)

func _goto_room(room_name: String, use_transition: bool = false) -> void:
	R.goto_room(room_name, use_transition)

# External function to get the current room
func _print_current_room() -> String:
	return R.current.script_name

# Update Ink variables from Popochiu globals
func _sync_ink_variables_from_popochiu() -> void:
	for variable in _current_story._story.variables_state.enumerate():
		if Globals.get(variable) != null:
			# print("Setting variable %s to %s" % [variable, Globals.get(variable)])
			_current_story._story.variables_state.set_variable(variable, Globals.get(variable))
			# print("Variable %s is now %s" % [variable, _current_story._story.variables_state.get_variable(variable)])

# Update Popochiu globals from Ink variables
func _sync_ink_variables_to_popochiu() -> void:
	# print("Syncing ink variables to popochiu")
	
	for variable in _current_story._story.variables_state.enumerate():
		# print("Variable name is %s" % variable)
		if Globals.get(variable) != null:
			if Globals.get(variable) != _current_story._story.variables_state.get_variable(variable):
				# print("Setting %s from %s to %s" % [variable, Globals.get(variable), _current_story._story.variables_state.get_variable(variable)])
				Globals.set(variable, _current_story._story.variables_state.get_variable(variable))


#region Public #####################################################################################

func play(knot: String) -> void:
	# print("Playing knot: %s " % knot)

	_sync_ink_variables_from_popochiu()
	
	# Jump to given knot
	if knot:
		_current_story.choose_path(knot)
		
	await _continue_story()

	# Handled by observing variables
	# _sync_ink_variables_to_popochiu()


func save(slot := 1) -> void:
	_current_story.save_state_to_path(SAVE_GAME_PATH % slot)

func load(slot := 1) -> void:
	_current_story.load_state_from_path(SAVE_GAME_PATH % slot)

#endregion
