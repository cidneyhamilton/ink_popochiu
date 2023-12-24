extends Node

# Emitted when the story has ended
signal story_ended

const REGEX_TEXT="(?<character>[\\w]+):\\s*(?<text>.+)"
const REGEX_COMMAND=">>\\s*(?<command>.+)"

var Story = preload("res://addons/inkgd/runtime/story.gd")
var _current_story = null
var ink_file = "res://ink/story.ink.json"

var _regex_text : RegEx = RegEx.new()
var _regex_command : RegEx = RegEx.new()

func _ready() -> void:
	_regex_text.compile(REGEX_TEXT)
	_regex_command.compile(REGEX_COMMAND)

func _get_story(ink_file: String):
	var ink_story = File.new()
	ink_story.open(ink_file, File.READ)
	var content = ink_story.get_as_text()
	ink_story.close()
	return Story.new(content)

func _continue_story() -> void:
	if _current_story.can_continue:
		var text : String = _current_story.continue()
		var text_info : RegExMatch = _regex_text.search(text)
		var command_info :RegExMatch = _regex_command.search(text)
		if text_info:
			_say(text_info.get_string("character"), text_info.get_string("text"))
		_continue_story()
	else:
		# End story
		pass

func _say(character: String, text: String) -> void:
	yield(E.run([
		C.character_say(character, text)
	]), 'completed')
	
func Play(knot: String) -> void:
	_current_story = _get_story(ink_file)
	_continue_story()
	
	
	
