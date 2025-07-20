## A complete wobble control panel using the new slider components
## Provides a consistent interface for all wobble parameters
extends Control
class_name WobbleControlPanel

## Reference to all wobble sliders
@onready var x_frequency_slider: WobbleSlider = $VBoxContainer/XFrequencySlider
@onready var x_amplitude_slider: WobbleSlider = $VBoxContainer/XAmplitudeSlider
@onready var y_frequency_slider: WobbleSlider = $VBoxContainer/YFrequencySlider
@onready var y_amplitude_slider: WobbleSlider = $VBoxContainer/YAmplitudeSlider
@onready var r_frequency_slider: WobbleSlider = $VBoxContainer/RFrequencySlider
@onready var r_amplitude_slider: WobbleSlider = $VBoxContainer/RAmplitudeSlider

## Array of all wobble sliders for easy iteration
var wobble_sliders: Array[WobbleSlider] = []

## The sprite currently being edited
var target_sprite = null

func _ready():
	# Collect all wobble sliders
	wobble_sliders = [
		x_frequency_slider,
		x_amplitude_slider,
		y_frequency_slider,
		y_amplitude_slider,
		r_frequency_slider,
		r_amplitude_slider
	]
	
	# Connect to wobble sync control if it exists
	var wobble_sync_control = find_child("WobbleSyncControl")
	if wobble_sync_control:
		_connect_wobble_sync_signals(wobble_sync_control)

## Set the target sprite for all sliders
func set_target_sprite(sprite):
	target_sprite = sprite
	for slider in wobble_sliders:
		slider.set_target_sprite(sprite)

## Update all sliders from the current sprite
func update_from_sprite():
	if target_sprite:
		for slider in wobble_sliders:
			slider._update_from_sprite()

## Update visual feedback for sync status
func update_sync_feedback():
	for slider in wobble_sliders:
		slider._update_sync_feedback()

## Connect signals from wobble sync control
func _connect_wobble_sync_signals(wobble_sync_control):
	# Connect value change signals to update wobble sync control
	for slider in wobble_sliders:
		slider.value_changed.connect(_on_wobble_parameter_changed)

## Handle wobble parameter changes to update sync control
func _on_wobble_parameter_changed(value: float):
	var wobble_sync_control = find_child("WobbleSyncControl")
	if wobble_sync_control and wobble_sync_control.has_method("updateUI"):
		wobble_sync_control.updateUI()
