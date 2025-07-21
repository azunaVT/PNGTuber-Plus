class_name NDIOutputManager
extends Node

## NDI Output Manager for PNGTuber-Plus
## Handles NDI streaming output for OBS integration
##
## This class manages the NDI output functionality, allowing the PNGTuber-Plus
## avatar to be streamed as an NDI source that can be captured by OBS Studio
## or other NDI-compatible applications.

@export var ndi_source_name: String = "PNGTuber-Plus"
@export var enable_audio: bool = true
@export var audio_bus_name: String = "Master"
@export var auto_start: bool = true

var ndi_output: NDIOutput
var is_streaming: bool = false

## Called when the node enters the scene tree
func _ready() -> void:
	if auto_start:
		initialize_ndi_output()

## Initialize the NDI output node and configure it
func initialize_ndi_output() -> void:
	# Create NDI output node if it doesn't exist
	if not ndi_output:
		ndi_output = NDIOutput.new()
		add_child(ndi_output)
	
	# Configure NDI output settings
	configure_ndi_output()
	
	print("NDI Output initialized with source name: ", ndi_source_name)

## Configure the NDI output with current settings
func configure_ndi_output() -> void:
	if not ndi_output:
		push_error("NDI Output node not found")
		return
	
	# Set the NDI source name
	ndi_output.name = ndi_source_name
	
	# Configure audio if enabled
	if enable_audio:
		ndi_output.audio_bus = StringName(audio_bus_name)
	
	print("NDI Output configured - Name: ", ndi_source_name, " Audio: ", enable_audio)

## Start NDI streaming
func start_streaming() -> void:
	if not ndi_output:
		initialize_ndi_output()
	
	if ndi_output and not is_streaming:
		is_streaming = true
		print("NDI streaming started - Source: ", ndi_source_name)

## Stop NDI streaming
func stop_streaming() -> void:
	if ndi_output and is_streaming:
		is_streaming = false
		print("NDI streaming stopped")

## Toggle NDI streaming on/off
func toggle_streaming() -> bool:
	if is_streaming:
		stop_streaming()
		return false
	else:
		start_streaming()
		return true

## Update the NDI source name
func set_source_name(new_name: String) -> void:
	ndi_source_name = new_name
	if ndi_output:
		ndi_output.name = ndi_source_name
		print("NDI source name changed to: ", ndi_source_name)

## Enable or disable audio streaming
func set_audio_enabled(enabled: bool) -> void:
	enable_audio = enabled
	if ndi_output:
		if enable_audio:
			ndi_output.audio_bus = StringName(audio_bus_name)
		else:
			ndi_output.audio_bus = StringName("")
		print("NDI audio ", "enabled" if enabled else "disabled")

## Change the audio bus for NDI output
func set_audio_bus(bus_name: String) -> void:
	audio_bus_name = bus_name
	if ndi_output and enable_audio:
		ndi_output.audio_bus = StringName(audio_bus_name)
		print("NDI audio bus changed to: ", audio_bus_name)

## Get current streaming status
func get_streaming_status() -> bool:
	return is_streaming

## Get current NDI source name
func get_source_name() -> String:
	return ndi_source_name

## Clean up when node is removed
func _exit_tree() -> void:
	if ndi_output and is_streaming:
		stop_streaming()
