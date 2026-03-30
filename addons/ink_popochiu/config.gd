@tool
class_name InkPopochiuConfig
extends RefCounted

const DEFAULT_PATH = "res://ink/ink.story.json"
const STORY_SETTING = "ink_pochiu/story"

static func init_settings() -> void:
	if !ProjectSettings.has_setting(STORY_SETTING):
		ProjectSettings.set_setting(STORY_SETTING, DEFAULT_PATH)

	var template_property_info = {
		"name": STORY_SETTING,
		"type": TYPE_STRING,
		"hint_string": "Path to ink story",
		"default": false
		}

	ProjectSettings.add_property_info(template_property_info)
