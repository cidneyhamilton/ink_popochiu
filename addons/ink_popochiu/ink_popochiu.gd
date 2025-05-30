class_name InkPopochiu
extends Node

const REGEX_TEXT = "^(?<character>[\\w]+):\\s*(?<text>.+)"
const REGEX_COMMAND = ">>>\\s*(?<command>.+)"

var InkPlayerFactory = preload("res://addons/inkgd/ink_player_factory.gd") as GDScript

var _current_story : InkPlayer = InkPlayerFactory.create()
var _regex_text: RegEx = RegEx.new()
var _regex_command: RegEx = RegEx.new()

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
		if Globals.get(variable) == null:
			print("Ink variable %s not found in the Popochiu globals" % variable)
		else:
			_current_story.observe_variable(variable, self, "_observe_variable")
			_current_story._story.variables_state.set_variable(variable, Globals.get(variable))
			# print("Binding variable %s to %s" % [variable, Globals.get(variable)])

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
			await _say(text_info.get_string("character"), text_info.get_string("text"))
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
	print("Attempting to run command: %s" % command)
	var command_arr = command.split(": ")
	var command_name = command_arr[0]
	var command_args = []
	if command_arr.size() > 1:
		command_args = command_arr[1].split(", ")
	await _run_command_with_args(command_name, command_args)

# Virtual: can be overridden with custom commands. These are Popochiu's default.
func _run_command_with_args(command_name: String, command_args: Array) -> void:
	match command_name:
		"GOTO_ROOM":
			var room = command_args[0]
			# Make sure the player can move during the transition
			C.player.can_move = true
			_goto_room(room)
		"WALK_TO_MARKER":
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).walk_to_marker(marker_name)
			# print("Reached marker")
		"TELEPORT_TO_MARKER":			
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).teleport_to_marker(marker_name)
		"FACE_LEFT":			
			var char_name = command_args[0]
			await C.get_character(char_name).face_left()
		"FACE_RIGHT":
			var char_name = command_args[0]
			await C.get_character(char_name).face_right()
		"FACE_UP":			
			var char_name = command_args[0]
			await C.get_character(char_name).face_up()
		"FACE_DOWN":
			var char_name = command_args[0]
			await C.get_character(char_name).face_down()
		"PLAY_SFX":
			var sfx_name = command_args[0]
			await _play_sfx(sfx_name)
		"STOP_SFX":
			var sfx_name = command_args[0]
			await _stop_sfx(sfx_name)
		"WAIT":
			var duration : float = float(command_args[0])
			await _wait(duration)
		"ANIMATE_CHARACTER":
			var char_name : String = command_args[0]
			var animation_name : String = command_args[1]
			await _animate_character(char_name, animation_name)
		"ANIMATE_PROP":
			var prop_name : String = command_args[0]
			var animation_name: String = command_args[1]
			await _animate_prop(prop_name, animation_name)
		"SET_CHARACTER_FLAG":
			var char_name: String = command_args[0]
			var state_var: String = command_args[1]
			var state_val: bool = command_args[2] == "true" 
			await _set_character_state(char_name, state_var, state_val)
		"SET_ROOM_FLAG":
			var room_name: String = command_args[0]
			var state_var: String = command_args[1]
			var state_val: bool = command_args[2] == "true" 
			await _set_room_state(room_name, state_var, state_val)
		"ADD_ITEM":
			var item_name : String = command_args[0]
			await _add_item(item_name)
			# Hide prop in room
			R.current.get_prop(item_name).hide()
		"WALK_TO_CLICKED":
			await C.player.walk_to_clicked_blocking()
		"FACE_CLICKED":
			await C.player.face_clicked()
		"CHARACTER_HIDE":
			var char_name = command_args[0]
			C.get_character(char_name).hide()
		_:
			print("Command not found")


# Allow player to choose a dialog option
func _choose() -> void:
	var opts = []
	for choice in _current_story.current_choices:
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
	await C.get_character(character).say(text)
	print("%s: %s" % [character, text])
	await _continue_story()


# Update Popochiu's globals whenever a variable in ink changes
func _observe_variable(variable_name: String, value) -> void:
	# print("Variable %s updated from ink" % variable_name)
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

func _set_room_state(room_name: String, state_key: String, state_val: bool) -> void:
	R.get_runtime_room(room_name).state[state_key] = state_val
	
func _animate_character(char_name: String, anim_name: String) -> void:
	print("Changing %s anim to %s" % [char_name, anim_name])
	await C.get_character(char_name).play_animation(anim_name)

func _animate_prop(prop_name: String, anim_name: String) -> void:
	await R.get_prop(prop_name).animate(anim_name)
	
func _face_up(char_name: String) -> void:
	await C.get_character(char_name).face_up()

func _face_down(char_name: String) -> void:
	await C.get_character(char_name).face_down()

func _face_left(char_name: String) -> void:
	await C.get_character(char_name).face_left()

func _face_right(char_name: String) -> void:
	await C.get_character(char_name).face_right()

func _play_sfx(sfx_name: String) -> void:
	A[sfx_name].play()

func _stop_sfx(sfx_name: String) -> void:
	A[sfx_name].stop(0)
	
func _add_item(item_name: String) -> void:
	I.get_item_instance(item_name).add()

func _remove_item(item_name: String) -> void:
	I.get_item_instance(item_name).remove()

func _wait(duration: float) -> void:
	await E.wait(duration)

func _goto_room(room_name: String) -> void:
	R.goto_room(room_name)
	
# Update Ink variables from Popochiu globals
func _sync_ink_variables_from_popochiu() -> void:
	for variable in _current_story._story.variables_state.enumerate():
		if Globals.get(variable) != null:
			# print("Setting variable %s to %s" % [variable, Globals.get(variable)])
			_current_story._story.variables_state.set_variable(variable, Globals.get(variable))
			# print("Variable %s is now %s" % [variable, _current_story._story.variables_state.get_variable(variable)])

# Update Popochiu globals from Ink variables
func _sync_ink_variables_to_popochiu() -> void:
	for variable in _current_story._story.variables_state.enumerate():
		if Globals.get(variable) != null:
			Globals.set(variable, _current_story._story.variables_state.get_variable(variable))


#region Public #####################################################################################

func play(knot: String) -> void:
	print("Playing knot: %s " % knot)

	_sync_ink_variables_from_popochiu()
	
	# Jump to given knot
	if knot:
		_current_story.choose_path(knot)
		
	await _continue_story()

	# Should be observing and setting variables, so no need to sync back
	

	
#endregion
