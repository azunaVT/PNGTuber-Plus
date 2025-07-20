@tool
## A parameter slider component for general sprite parameters
## Handles updating sprite properties with proper formatting
extends LabeledSlider
class_name ParameterSlider

## The sprite parameter name this slider controls
@export var parameter_name: String = ""
## The property path in the sprite object (e.g., "dragSpeed", "rdragStr")
@export var sprite_property: String = ""

## Reference to the sprite being edited
var target_sprite = null

func _ready():
	super._ready()
	# Connect to value changes to update parameters
	value_changed.connect(_on_parameter_value_changed)

func _notification(what):
	super._notification(what)
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		# Update label for opacity specially
		if sprite_property == "spriteOpacity":
			call_deferred("_update_opacity_label")

## Set the sprite this slider controls
func set_target_sprite(sprite):
	target_sprite = sprite
	if sprite:
		_update_from_sprite()

## Update the slider from the sprite's current values
func _update_from_sprite():
	if not target_sprite or sprite_property == "":
		return
	
	var current_value = target_sprite.get(sprite_property)
	if current_value != null:
		set_value(current_value)
		
		# Special handling for opacity display
		if sprite_property == "spriteOpacity":
			_update_opacity_label()

## Update label text with special opacity handling
func _update_opacity_label():
	if sprite_property == "spriteOpacity" and label:
		var percentage = int(value * 100)
		label.text = label_text + ": " + str(percentage) + "%"

## Override base update_label for special cases
func _update_label():
	if sprite_property == "spriteOpacity":
		_update_opacity_label()
	else:
		super._update_label()

## Handle parameter changes
func _on_parameter_value_changed(new_value: float):
	if not target_sprite or sprite_property == "":
		return
	
	
	target_sprite.set(sprite_property, new_value)
	
	# Call specific update methods if they exist
	_call_update_method()

## Call specific update methods for certain parameters
func _call_update_method():
	if not target_sprite:
		return
	
	match sprite_property:
		"spriteOpacity":
			target_sprite.updateOpacity()
		"frames":
			target_sprite.changeFrames()
		"blendMode":
			target_sprite.updateBlendMode(value)
