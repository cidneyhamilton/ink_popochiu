extends Node

const REGEX_TEXT = "(?<character>[\\w]+):\\s*(?<text>.+)"
const REGEX_COMMAND = ">>>\\s*(?<command>.+)"

var InkPlayerFactory = preload("res://addons/inkgd/ink_player_factory.gd") as GDScript
var ink_file = preload( "res://ink/story.ink.json")

var _current_story : InkPlayer = InkPlayerFactory.create()

var _regex_text: RegEx = RegEx.new()
var _regex_command: RegEx = RegEx.new()


# TODO: Check character and room states
@export var _custom_functions: Array = [
]

func _ready() -> void:
	_current_story.loads_in_background = true
	
	add_child(_current_story)
	
	_current_story.ink_file = ink_file
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
		
	print("Ink story loaded")
	_bind_functions(_custom_functions)

	# Store variables
	for variable in _current_story._story.variables_state.enumerate():
		if Globals.get(variable) == null:
			print("Ink variable %s not found in the Popochiu globals" % variable)
		_current_story.observe_variable(variable, self, "_observe_variable")
		_current_story._story.variables_state.set(variable, Globals.get(variable))


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
			print("Narrator: %s" % text)
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
	var command_args = command_arr[1].split(", ")
	_run_command_with_args(command_name, command_args)

# Virtual: can be overridden with custom commands. These are Popochiu's default.
func _run_command_with_args(command_name: String, command_args: Array) -> void:
	match command_name:
		"WALK_TO_MARKER":
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).walk_to_marker(marker_name)
		"TELEPORT_TO_MARKER":			
			var char_name = command_args[0]
			var marker_name = command_args[1]
			await C.get_character(char_name).teleport_to_marker(marker_name)
		"FACE_LEFT":			
			var char_name = command_args[0]
			await C.get_character(char_name).face_left()
		"FACE_RIGHT":
			var char_name = command_args[0]
			await C.get_character(char_name).face_left()
		"PLAY_SFX":
			var sfx_name = command_args[0]
			await _play_sfx(sfx_name)
		"WAIT":
			var duration : float = float(command_args[0])
			await _wait(duration)
		"ANIMATE_CHARACTER":
			var char_name : String = command_args[0]
			var animation_name : String = command_args[1]
			await _animate_character(char_name, animation_name)
		"SET_CHARACTER_FLAG":
			var char_name: String = command_args[0]
			var state_var: String = command_args[1]
			var state_val: bool = command_args[2] == "true" 
			await _set_character_state(char_name, state_var, state_val)


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
	Globals.set(variable_name, value)

func _bind_functions(function_list: Array) -> void:
	for function_name in function_list:
		_current_story.bind_external_function(function_name, self, "_%s" % function_name, false)

func _teleport_to_marker(char_name: String, marker_name: String) -> void:
	C.get_character(char_name).teleport_to_marker(marker_name)
	
func _walk_to_marker(char_name: String, marker_name: String) -> void:
	C.get_character(char_name).walk_to_marker(marker_name)

func _set_character_state(char_name: String, state_key: String, state_val: bool) -> void:
	C.get_character(char_name).state[state_key] = state_val

func _set_room_state(room_name: String, state_key: String, state_val: bool) -> void:
	R.get_runtime_room(room_name).state[state_key] = state_val
	
func _animate_character(char_name: String, anim_name: String) -> void:
	C.get_character(char_name).get_node("AnimationPlayer").play(anim_name)

func _face_up(char_name: String) -> void:
	C.get_character(char_name).face_up()

func _face_down(char_name: String) -> void:
	C.get_character(char_name).face_down()

func _face_left(char_name: String) -> void:
	C.get_character(char_name).face_left()

func _face_right(char_name: String) -> void:
	C.get_character(char_name).face_right()

func _play_sfx(sfx_name: String) -> void:
	A[sfx_name].play()

func _add_item(item_name: String) -> void:
	I.get_item_instance(item_name).add()

func _remove_item(item_name: String) -> void:
	I.get_item_instance(item_name).remove()

func _wait(duration: float) -> void:
	await E.wait(duration)
	
#region Public #####################################################################################

func play(knot: String) -> void:
		
	# Jump to given knot
	if knot:
		_current_story.choose_path(knot)
		
	await _continue_story()
	
#endregion
