extends Node

const REGEX_TEXT = "(?<character>[\\w]+):\\s*(?<text>.+)"
const REGEX_COMMAND = ">>\\s*(?<command>.+)"

var Story = preload("res://addons/inkgd/runtime/ink_story.gd")
var _current_story = null

# TODO: Specify this in configuration
var ink_file = "res://ink/story.ink.json"

var _regex_text: RegEx = RegEx.new()
var _regex_command: RegEx = RegEx.new()


func _ready() -> void:
	_regex_text.compile(REGEX_TEXT)
	_regex_command.compile(REGEX_COMMAND)


# Initializes the story from a file
func _get_story(ink_file: String):
	var ink_story = FileAccess.open(ink_file, FileAccess.READ)
	var content = ink_story.get_as_text()
	ink_story.close()
	var runtime = get_node("/root/")
	return Story.new(content, InkRuntime)


# Continues the story
func _continue_story() -> void:
	if _current_story.can_continue:
		print("Story can continue")
		var text: String = _current_story.continue_story()
		var text_info: RegExMatch = _regex_text.search(text)
		var command_info: RegExMatch = _regex_command.search(text)
		if command_info:
			_run_command(command_info.get_string("command"))
		elif text_info:
			_say(text_info.get_string("character"), text_info.get_string("text"))
		else:
			print("Text doesn't match form <character name>:<text>: %s" % text)
			_continue_story()
	elif _current_story.current_choices.size() > 0:
		print("Showing choices")
		_choose()
	else:
		pass


# Runs a given command from ink
func _run_command(command: String) -> void:
	print("Attempting to run command: %s", command)
	# TODO
	_continue_story()


# Allow player to choose a dialog option
func _choose() -> void:
	var opts = []
	for choice in _current_story.current_choices:
		opts.push_back(choice.text)

	var selection : PopochiuDialogOption = await D.show_inline_dialog(opts)
	
	_choose_option(selection)


# Choose the given dialog option and continue the story
func _choose_option(opt: PopochiuDialogOption) -> void:
	var i := 0
	for choice in _current_story.current_choices:
		if choice.text == opt.text:
			_current_story.choose_choice_index(i)
			# Don't allow dialog to repeat itself
			_current_story.continue_story()
		i += 1
	_continue_story()


# Say a line of text and continue the story
func _say(character: String, text: String) -> void:
	await C.get_character(character).say(text)
	_continue_story()


# Update Popochiu's globals whenever a variable in ink changes
func _observe_variable(variable_name: String, value) -> void:
	Globals.set(variable_name, value)


func Play(knot: String) -> void:
	_current_story = _get_story(ink_file)

	# Store variables
	for variable in _current_story.variables_state.enumerate():
		if Globals.get(variable) == null:
			print("Ink variable %s not found in the Popochiu globals" % variable)
		_current_story.observe_variable(variable, self, "_observe_variable")
		_current_story.variables_state.set(variable, Globals.get(variable))

	# Jump to given knot
	if knot:
		_current_story.choose_path_string(knot)

	_continue_story()
