## Manages all slider components in the sprite viewer
## Provides a centralized way to update and configure sliders
extends RefCounted
class_name SliderManager

## Array of all slider components
var sliders: Array[LabeledSlider] = []
## Reference to the sprite viewer
var sprite_viewer = null

func _init(viewer):
	sprite_viewer = viewer

## Add a slider to be managed
func add_slider(slider: LabeledSlider):
	if slider not in sliders:
		sliders.append(slider)

## Remove a slider from management
func remove_slider(slider: LabeledSlider):
	sliders.erase(slider)

## Update all sliders with the current sprite data
func update_all_sliders(sprite):
	for slider in sliders:
		if slider is WobbleSlider:
			slider.set_target_sprite(sprite)
		elif slider is ParameterSlider:
			slider.set_target_sprite(sprite)

## Update wobble control states based on sync status
func update_wobble_control_states(sprite):
	if not sprite:
		return
	
	var is_synced = sprite.isSynced()
	
	for slider in sliders:
		if slider is WobbleSlider:
			# Keep wobble controls enabled even when synced (they edit group settings)
			slider.set_editable(true)
			
			# Visual feedback for sync state - slight tint to indicate group editing
			var tint = Color(1.0, 1.0, 0.9) if is_synced else Color.WHITE
			slider.set_modulate_color(tint)

## Get a slider by its parameter name
func get_slider_by_parameter(parameter_name: String) -> LabeledSlider:
	for slider in sliders:
		if slider is WobbleSlider and slider.parameter_name == parameter_name:
			return slider
		elif slider is ParameterSlider and slider.sprite_property == parameter_name:
			return slider
	return null

## Apply consistent styling to all sliders
func apply_consistent_styling():
	for slider in sliders:
		# Apply any consistent styling here
		pass
