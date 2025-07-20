@tool
## A specialized slider component for wobble parameters
## Automatically handles syncing with wobble groups and provides appropriate feedback
extends LabeledSlider
class_name WobbleSlider

## The wobble parameter name this slider controls
@export var parameter_name: String = ""

## Reference to the sprite being edited
var target_sprite = null

func _ready():
	super._ready()
	# Connect to value changes to update wobble parameters
	value_changed.connect(_on_wobble_value_changed)

## Set the sprite this slider controls
func set_target_sprite(sprite):
	target_sprite = sprite
	if sprite:
		_update_from_sprite()

## Update the slider from the sprite's current values
func _update_from_sprite():
	if not target_sprite or parameter_name == "":
		return
	
	match parameter_name:
		"xFrq":
			set_value(target_sprite.xFrq)
		"xAmp":
			set_value(target_sprite.xAmp)
		"yFrq":
			set_value(target_sprite.yFrq)
		"yAmp":
			set_value(target_sprite.yAmp)
		"rFrq":
			set_value(target_sprite.rFrq)
		"rAmp":
			set_value(target_sprite.rAmp)

## Handle wobble parameter changes
func _on_wobble_value_changed(new_value: float):
	if not target_sprite or parameter_name == "":
		return
	
	target_sprite.updateWobbleParameter(parameter_name, new_value)
	
	# Update visual feedback for sync status
	_update_sync_feedback()

## Update visual feedback based on sync status
func _update_sync_feedback():
	if not target_sprite:
		return
	
	var is_synced = target_sprite.isSynced()
	var tint = Color(1.0, 1.0, 0.9) if is_synced else Color.WHITE
	set_modulate_color(tint)
