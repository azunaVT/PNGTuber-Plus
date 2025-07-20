@tool
## A reusable component that combines a label and slider
## Provides consistent formatting and behavior for all sliders in the UI
extends VBoxContainer
class_name LabeledSlider

## Emitted when the slider value changes
signal value_changed(value: float)

## The base text that appears in the label (without the value)
@export var label_text: String = "Value" : set = set_label_text
## The minimum value of the slider
@export var min_value: float = 0.0 : set = set_min_value
## The maximum value of the slider
@export var max_value: float = 100.0 : set = set_max_value
## The step value for the slider
@export var step: float = 1.0 : set = set_step
## The current value of the slider
@export var value: float = 0.0 : set = set_value
## Whether to show the value in the label
@export var show_value_in_label: bool = true : set = set_show_value_in_label
## Format string for the value display (e.g., "%.1f" for one decimal place)
@export var value_format: String = "%.0f" : set = set_value_format
## Optional suffix to add after the value (e.g., "%", "Hz")
@export var value_suffix: String = "" : set = set_value_suffix
## Whether the slider is editable
@export var editable: bool = true : set = set_editable

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

func _ready():
	if slider:
		slider.value_changed.connect(_on_slider_value_changed)
		_update_slider_properties()
	
	# Ensure label is updated after all properties are set
	call_deferred("_update_label")

func _notification(what):
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		# Update label when scene is instantiated (important for editor)
		call_deferred("_update_label")

## Set the label text
func set_label_text(new_text: String):
	label_text = new_text
	if is_inside_tree():
		_update_label()
	else:
		call_deferred("_update_label")

## Set the minimum value
func set_min_value(new_min: float):
	min_value = new_min
	if is_inside_tree():
		_update_slider_properties()

## Set the maximum value
func set_max_value(new_max: float):
	max_value = new_max
	if is_inside_tree():
		_update_slider_properties()

## Set the step value
func set_step(new_step: float):
	step = new_step
	if is_inside_tree():
		_update_slider_properties()

## Set the current value
func set_value(new_value: float):
	value = new_value
	if slider:
		slider.value = value
	if is_inside_tree():
		_update_label()

## Set whether to show value in label
func set_show_value_in_label(show: bool):
	show_value_in_label = show
	if is_inside_tree():
		_update_label()

## Set the value format string
func set_value_format(format: String):
	value_format = format
	if is_inside_tree():
		_update_label()

## Set the value suffix
func set_value_suffix(suffix: String):
	value_suffix = suffix
	if is_inside_tree():
		_update_label()

## Set whether the slider is editable
func set_editable(is_editable: bool):
	editable = is_editable
	if slider:
		slider.editable = editable

## Update the slider properties
func _update_slider_properties():
	if not slider:
		return
	
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.editable = editable

## Update the label text
func _update_label():
	if not label:
		# If label isn't ready yet, try to find it
		label = get_node_or_null("Label")
		if not label:
			# Call again after a frame when nodes are ready
			call_deferred("_update_label")
			return
	
	var text = label_text
	if show_value_in_label:
		var formatted_value = value_format % value
		text += ": " + formatted_value + value_suffix
	
	label.text = text

## Handle slider value changes
func _on_slider_value_changed(new_value: float):
	value = new_value
	_update_label()
	value_changed.emit(value)

## Set the modulate color for visual feedback
func set_modulate_color(color: Color):
	if slider:
		slider.modulate = color
