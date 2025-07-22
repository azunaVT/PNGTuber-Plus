extends SubViewport

## NDI Avatar Viewport Controller
## Handles avatar-only NDI streaming with synchronized states

#Node Reference
@onready var origin = $OriginMotion/Origin
@onready var ndi_output = $NDIOutput

## Initialize viewport settings for transparent background and avatar mirroring
func _ready():
	# Set transparent background
	transparent_bg = true
	
	# Connect to the main scene for state sync
	if Global.main:
		Global.main.connect("spriteVisToggles", Callable(self, "_on_sprite_visibility_toggle"))
		Global.main.connect("bounceChange", Callable(self, "_sync_bounce"))

## Sync avatar sprites from main scene to this viewport
func sync_avatar():
	# Clear existing sprites
	for child in origin.get_children():
		child.queue_free()
	
	# Wait for cleanup
	await get_tree().process_frame
	
	# Get sprites from main scene
	var main_sprites = get_tree().get_nodes_in_group("saved")
	for sprite in main_sprites:
		clone_sprite(sprite)

## Clone a sprite from main scene to this viewport
func clone_sprite(original_sprite):
	# Create new instance
	var sprite_scene = preload("res://ui_scenes/selectedSprite/spriteObject.tscn")
	var cloned_sprite = sprite_scene.instantiate()
	
	# Copy all properties
	cloned_sprite.path = original_sprite.path
	cloned_sprite.id = original_sprite.id
	cloned_sprite.parentId = original_sprite.parentId
	cloned_sprite.displayName = original_sprite.displayName
	
	# Visual properties
	cloned_sprite.offset = original_sprite.offset
	cloned_sprite.z = original_sprite.z
	cloned_sprite.position = original_sprite.position
	
	# Physics properties
	cloned_sprite.dragSpeed = original_sprite.dragSpeed
	cloned_sprite.xFrq = original_sprite.xFrq
	cloned_sprite.xAmp = original_sprite.xAmp
	cloned_sprite.yFrq = original_sprite.yFrq
	cloned_sprite.yAmp = original_sprite.yAmp
	cloned_sprite.rFrq = original_sprite.rFrq
	cloned_sprite.rAmp = original_sprite.rAmp
	cloned_sprite.rdragStr = original_sprite.rdragStr
	cloned_sprite.rLimitMin = original_sprite.rLimitMin
	cloned_sprite.rLimitMax = original_sprite.rLimitMax
	cloned_sprite.stretchAmount = original_sprite.stretchAmount
	cloned_sprite.ignoreBounce = original_sprite.ignoreBounce
	
	# Animation properties
	cloned_sprite.frames = original_sprite.frames
	cloned_sprite.animSpeed = original_sprite.animSpeed
	
	# Visibility properties
	cloned_sprite.showOnTalk = original_sprite.showOnTalk
	cloned_sprite.showOnBlink = original_sprite.showOnBlink
	cloned_sprite.costumeLayers = original_sprite.costumeLayers.duplicate()
	cloned_sprite.spriteOpacity = original_sprite.spriteOpacity
	cloned_sprite.affectChildrenOpacity = original_sprite.affectChildrenOpacity
	cloned_sprite.blendMode = original_sprite.blendMode
	cloned_sprite.toggle = original_sprite.toggle
	cloned_sprite.clipped = original_sprite.clipped
	
	# Transform properties
	cloned_sprite.staticRotation = original_sprite.staticRotation
	cloned_sprite.mirrorHorizontal = original_sprite.mirrorHorizontal
	cloned_sprite.mirrorVertical = original_sprite.mirrorVertical
	
	# Wobble sync
	cloned_sprite.wobbleSyncGroup = original_sprite.wobbleSyncGroup
	
	# Add to origin
	origin.add_child(cloned_sprite)
	
	# Apply current costume visibility
	if Global.main:
		var current_costume = Global.main.costume
		if cloned_sprite.costumeLayers[current_costume - 1] == 1:
			cloned_sprite.visible = true
		else:
			cloned_sprite.visible = false

## Process function to keep sprites in sync with main scene
func _process(delta):
	if !Global.main:
		return
	
	# Sync origin position with bounce from main scene
	$OriginMotion.position.y = 360 + Global.main.bounceChange
	
	# Sync sprites with main scene
	var main_sprites = get_tree().get_nodes_in_group("saved")
	var avatar_sprites = origin.get_children()
	
	for i in range(min(main_sprites.size(), avatar_sprites.size())):
		sync_sprite_state(main_sprites[i], avatar_sprites[i])

## Sync individual sprite state
func sync_sprite_state(main_sprite, avatar_sprite):
	if !is_instance_valid(main_sprite) or !is_instance_valid(avatar_sprite):
		return
	
	# Sync position and transform
	avatar_sprite.position = main_sprite.position
	avatar_sprite.rotation = main_sprite.rotation
	avatar_sprite.scale = main_sprite.scale
	
	# Sync visibility based on costume
	if Global.main:
		var current_costume = Global.main.costume
		if avatar_sprite.costumeLayers[current_costume - 1] == 1:
			avatar_sprite.visible = main_sprite.visible
		else:
			avatar_sprite.visible = false
	
	# Sync animation frame
	if avatar_sprite.has_method("get_sprite") and main_sprite.has_method("get_sprite"):
		var avatar_spr = avatar_sprite.get_sprite()
		var main_spr = main_sprite.get_sprite()
		if avatar_spr and main_spr:
			avatar_spr.frame = main_spr.frame

## Handle sprite visibility toggles
func _on_sprite_visibility_toggle():
	sync_avatar()

## Sync bounce changes
func _sync_bounce(bounce_change):
	$OriginMotion.position.y = 360 + bounce_change
