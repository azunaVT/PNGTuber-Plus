extends Node

## Blend Mode Manager
##
## Manages blend mode constants and provides utility functions for 
## working with blend modes in the PNGTuber application.

## Blend mode constants
enum BlendMode {
	NORMAL = 0,
	MULTIPLY = 1,
	SCREEN = 2,
	OVERLAY = 3,
	SOFT_LIGHT = 4,
	HARD_LIGHT = 5,
	COLOR_DODGE = 6,
	COLOR_BURN = 7,
	DARKEN = 8,
	LIGHTEN = 9,
	ADD = 10,        # Linear Dodge
	SUBTRACT = 11
}

## Returns an array of blend mode names for use in dropdowns
static func get_blend_mode_names() -> Array:
	return [
		"Normal",
		"Multiply", 
		"Screen",
		"Overlay",
		"Soft Light",
		"Hard Light",
		"Color Dodge",
		"Color Burn",
		"Darken",
		"Lighten",
		"Add",
		"Subtract"
	]

## Returns the string name for a given blend mode enum value
static func get_blend_mode_name(mode: BlendMode) -> String:
	var names = get_blend_mode_names()
	if mode >= 0 and mode < names.size():
		return names[mode]
	return "Normal"

## Returns the blend mode enum value for a given name
static func get_blend_mode_from_name(name: String) -> BlendMode:
	var names = get_blend_mode_names()
	var index = names.find(name)
	if index != -1:
		return index as BlendMode
	return BlendMode.NORMAL

## Returns whether a blend mode is valid
static func is_valid_blend_mode(mode: int) -> bool:
	return mode >= BlendMode.NORMAL and mode <= BlendMode.SUBTRACT
