extends Node2D

#Node Reference
@onready var spriteSpin = $SubViewportContainer/SubViewport/Node3D/Sprite3D

@onready var parentSpin = $SubViewportContainer2/SubViewport/Node3D/Sprite3D

@onready var spriteRotDisplay = $VBoxContainer/RotationalLimitsSection/RotBack/SpriteDisplay


@onready var coverCollider = $Area2D/CollisionShape2D
@onready var wobbleSyncControl = null  # Will be assigned in _ready()
@onready var blendModeDropdown = $VBoxContainer/RenderingSection/blendModeContainer/blendModeDropdown

## Slider management system
var slider_manager: SliderManager = null

func _ready():
	Global.spriteEdit = self
	
	# Initialize slider management system
	slider_manager = SliderManager.new(self)
	_setup_slider_components()
	
	# Find the wobble sync control node
	wobbleSyncControl = find_child("WobbleSyncControl")
	
	# Set up blend mode dropdown
	setupBlendModeDropdown()

## Set up all slider components
func _setup_slider_components():
	# Initialize all the new slider components and add them to the manager
	_setup_drag_slider()
	_setup_wobble_sliders()
	_setup_rotation_sliders()
	_setup_limit_sliders()
	_setup_animation_sliders()
	_setup_opacity_slider()
	_setup_transform_sliders()

## Set up drag slider
func _setup_drag_slider():
	var drag_slider = $VBoxContainer/PhysicsSection/DragSlider
	if drag_slider:
		slider_manager.add_slider(drag_slider)
		drag_slider.value_changed.connect(_on_drag_slider_value_changed)

## Set up wobble sliders
func _setup_wobble_sliders():
	var wobble_sliders = [
		$VBoxContainer/WobbleSection/xFrqSlider,
		$VBoxContainer/WobbleSection/xAmpSlider,
		$VBoxContainer/WobbleSection/yFrqSlider,
		$VBoxContainer/WobbleSection/yAmpSlider,
		$VBoxContainer/WobbleSection/rFrqSlider,
		$VBoxContainer/WobbleSection/rAmpSlider
	]
	
	for slider in wobble_sliders:
		if slider:
			slider_manager.add_slider(slider)
			slider.value_changed.connect(_on_wobble_slider_changed)

## Set up rotation sliders
func _setup_rotation_sliders():
	var rotation_sliders = [
		$VBoxContainer/PhysicsSection/rDragSlider,
		$VBoxContainer/PhysicsSection/squashSlider
	]
	
	for slider in rotation_sliders:
		if slider:
			slider_manager.add_slider(slider)
			slider.value_changed.connect(_on_rotation_slider_changed)

## Set up rotational limit sliders
func _setup_limit_sliders():
	var limit_sliders = [
		$VBoxContainer/RotationalLimitsSection/rotLimitMinSlider,
		$VBoxContainer/RotationalLimitsSection/rotLimitMaxSlider
	]
	
	for slider in limit_sliders:
		if slider:
			slider_manager.add_slider(slider)
			slider.value_changed.connect(_on_limit_slider_changed)

## Set up animation sliders
func _setup_animation_sliders():
	var animation_sliders = [
		$VBoxContainer/AnimationSection/animFramesSlider,
		$VBoxContainer/AnimationSection/animSpeedSlider
	]
	
	for slider in animation_sliders:
		if slider:
			slider_manager.add_slider(slider)
			slider.value_changed.connect(_on_animation_slider_changed)

## Set up opacity slider
func _setup_opacity_slider():
	var opacity_slider = $VBoxContainer/RenderingSection/opacitySlider
	if opacity_slider:
		slider_manager.add_slider(opacity_slider)
		opacity_slider.value_changed.connect(_on_opacity_slider_changed)

## Set up transform sliders
func _setup_transform_sliders():
	var rotation_slider = $VBoxContainer/TransformSection/rotationSlider
	if rotation_slider:
		slider_manager.add_slider(rotation_slider)
		rotation_slider.value_changed.connect(_on_transform_slider_changed)

## Generic slider change handlers
func _on_drag_slider_value_changed(value: float):
	if Global.heldSprite:
		Global.heldSprite.dragSpeed = value

func _on_wobble_slider_changed(value: float):
	# Wobble sliders handle their own parameter updates
	# Just update the wobble sync control if needed
	if wobbleSyncControl:
		wobbleSyncControl.updateUI()

func _on_rotation_slider_changed(value: float):
	# Rotation sliders handle their own parameter updates
	if Global.heldSprite:
		changeRotLimit() # Update the rotation limit display

func _on_limit_slider_changed(value: float):
	# Limit sliders handle their own parameter updates
	if Global.heldSprite:
		changeRotLimit() # Update the rotation limit display

func _on_animation_slider_changed(value: float):
	# Animation sliders handle their own parameter updates
	if Global.heldSprite:
		# Special handling for frames slider
		var frames_slider = $VBoxContainer/AnimationSection/animFramesSlider
		if frames_slider and frames_slider.value != Global.heldSprite.frames:
			spriteSpin.hframes = Global.heldSprite.frames

func _on_opacity_slider_changed(value: float):
	# Opacity slider handles its own parameter updates via sprite_property
	pass

func _on_transform_slider_changed(value: float):
	# Transform sliders handle their own parameter updates via sprite_property
	pass
	
func setImage():
	if Global.heldSprite == null:
		return
	
	spriteSpin.texture = Global.heldSprite.tex
	spriteSpin.pixel_size = 1.5 / Global.heldSprite.imageData.get_size().y
	spriteSpin.hframes = Global.heldSprite.frames
	
	# Apply static rotation and mirroring to 3D preview
	spriteSpin.rotation = Vector3(0, 0, deg_to_rad(Global.heldSprite.staticRotation))
	var scale_x = -1.0 if Global.heldSprite.mirrorHorizontal else 1.0
	var scale_y = -1.0 if Global.heldSprite.mirrorVertical else 1.0
	spriteSpin.scale = Vector3(scale_x, scale_y, 1.0)
	
	spriteRotDisplay.texture = Global.heldSprite.tex
	spriteRotDisplay.offset = Global.heldSprite.offset
	var displaySize = Global.heldSprite.imageData.get_size().y
	spriteRotDisplay.scale = Vector2(1,1) * (150.0/displaySize)
	
	# Update all slider components with the current sprite
	if slider_manager:
		slider_manager.update_all_sliders(Global.heldSprite)
		
	# Update individual sliders with current values
	_update_all_slider_values()
	
	$Position/fileTitle.text = Global.heldSprite.path.replace("user://", "")
	
	
	
	$VBoxContainer/PhysicsSection/BounceVelocity.button_pressed = Global.heldSprite.ignoreBounce
	$VBoxContainer/RenderingSection/ClipLinked.button_pressed = Global.heldSprite.clipped
	
	
	$VBoxContainer/Buttons/SpeakingWrapper/Speaking.frame = Global.heldSprite.showOnTalk
	$VBoxContainer/Buttons/BlinkingWrapper/Blinking.frame = Global.heldSprite.showOnBlink
	
	$VBoxContainer/RenderingSection/affectChildrenCheck.button_pressed = Global.heldSprite.affectChildrenOpacity
	$VBoxContainer/RenderingSection/blendModeContainer/blendModeDropdown.selected = Global.heldSprite.blendMode
	
	# Update transform controls
	$VBoxContainer/TransformSection/MirrorControls/mirrorHorizontalCheck.button_pressed = Global.heldSprite.mirrorHorizontal
	$VBoxContainer/TransformSection/MirrorControls/mirrorVerticalCheck.button_pressed = Global.heldSprite.mirrorVertical
	
	$VBoxContainer/BoxContainer/setToggle/Label.text = "toggle: \"" + Global.heldSprite.toggle +  "\""
	
	changeRotLimit()
	
	setLayerButtons()
	
	# Update wobble sync control
	if wobbleSyncControl:
		wobbleSyncControl.setSprite(Global.heldSprite)
		# Force a refresh to ensure dropdown is populated
		await get_tree().process_frame
		wobbleSyncControl.updateUI()
	
	# Update wobble control states based on sync status
	updateWobbleControlStates()
	
	if Global.heldSprite.parentId == null:
		$VBoxContainer/Buttons/UnlinkWrapper/Unlink.visible = false
		parentSpin.visible = false
	else:
		$VBoxContainer/Buttons/UnlinkWrapper/Unlink.visible = true
		
		var nodes = get_tree().get_nodes_in_group(str(Global.heldSprite.parentId))
		
		if nodes.size()<=0:
			return
		
		parentSpin.texture = nodes[0].tex
		parentSpin.pixel_size = 1.5 / nodes[0].imageData.get_size().y
		parentSpin.hframes = nodes[0].frames
		parentSpin.visible = true

## Update all slider components with current sprite values
func _update_all_slider_values():
	if not Global.heldSprite:
		return
	
	# Update drag slider
	var drag_slider = $VBoxContainer/PhysicsSection/DragSlider
	if drag_slider:
		drag_slider.set_value(Global.heldSprite.dragSpeed)
	
	# Update wobble sliders
	var wobble_sliders = {
		$VBoxContainer/WobbleSection/xFrqSlider: Global.heldSprite.xFrq,
		$VBoxContainer/WobbleSection/xAmpSlider: Global.heldSprite.xAmp,
		$VBoxContainer/WobbleSection/yFrqSlider: Global.heldSprite.yFrq,
		$VBoxContainer/WobbleSection/yAmpSlider: Global.heldSprite.yAmp,
		$VBoxContainer/WobbleSection/rFrqSlider: Global.heldSprite.rFrq,
		$VBoxContainer/WobbleSection/rAmpSlider: Global.heldSprite.rAmp
	}
	
	for slider in wobble_sliders:
		if slider:
			slider.set_value(wobble_sliders[slider])
	
	# Update rotation sliders
	var rotation_sliders = {
		$VBoxContainer/PhysicsSection/rDragSlider: Global.heldSprite.rdragStr,
		$VBoxContainer/PhysicsSection/squashSlider: Global.heldSprite.stretchAmount
	}
	
	for slider in rotation_sliders:
		if slider:
			slider.set_value(rotation_sliders[slider])
	
	# Update limit sliders
	var limit_sliders = {
		$VBoxContainer/RotationalLimitsSection/rotLimitMinSlider: Global.heldSprite.rLimitMin,
		$VBoxContainer/RotationalLimitsSection/rotLimitMaxSlider: Global.heldSprite.rLimitMax
	}
	
	for slider in limit_sliders:
		if slider:
			slider.set_value(limit_sliders[slider])
	
	# Update animation sliders
	var animation_sliders = {
		$VBoxContainer/AnimationSection/animFramesSlider: Global.heldSprite.frames,
		$VBoxContainer/AnimationSection/animSpeedSlider: Global.heldSprite.animSpeed
	}
	
	for slider in animation_sliders:
		if slider:
			slider.set_value(animation_sliders[slider])
	
	# Update opacity slider
	var opacity_slider = $VBoxContainer/RenderingSection/opacitySlider
	if opacity_slider:
		opacity_slider.set_value(Global.heldSprite.spriteOpacity)
	
	# Update transform slider
	var rotation_slider = $VBoxContainer/TransformSection/rotationSlider
	if rotation_slider:
		rotation_slider.set_value(Global.heldSprite.staticRotation)

## Update wobble control states based on sync status
func updateWobbleControlStates():
	if Global.heldSprite == null:
		return
	
	# Use slider manager if available
	if slider_manager:
		slider_manager.update_wobble_control_states(Global.heldSprite)
	
	# Also update individual wobble sliders for visual feedback
	var is_synced = Global.heldSprite.isSynced()
	var tint = Color(1.0, 1.0, 0.9) if is_synced else Color.WHITE
	
	var wobble_sliders = [
		$VBoxContainer/WobbleSection/xFrqSlider,
		$VBoxContainer/WobbleSection/xAmpSlider,
		$VBoxContainer/WobbleSection/yFrqSlider,
		$VBoxContainer/WobbleSection/yAmpSlider,
		$VBoxContainer/WobbleSection/rFrqSlider,
		$VBoxContainer/WobbleSection/rAmpSlider
	]
	
	for slider in wobble_sliders:
		if slider and slider.has_method("set_modulate_color"):
			slider.set_modulate_color(tint)
			slider.set_editable(true) # Keep enabled even when synced
	
func _process(delta):

	visible = Global.heldSprite != null
	coverCollider.disabled = !visible
	
	if !visible:
		return
	
	var obj = Global.heldSprite
	spriteSpin.rotate_y(delta*4.0)
	parentSpin.rotate_y(delta*4.0)
	
	$VBoxContainer/InfoSection/PositionLabel.text = "position     X : "+str(obj.position.x)+"     Y: " + str(obj.position.y)
	$VBoxContainer/InfoSection/OffsetLabel.text = "offset         X : "+str(obj.offset.x)+"     Y: " + str(obj.offset.y)
	$VBoxContainer/InfoSection/LayerLabel.text = "layer : "+str(obj.z)
	
	#Sprite Rotational Limit Display
		
	var size = Global.heldSprite.rLimitMax - Global.heldSprite.rLimitMin
	var minimum = Global.heldSprite.rLimitMin
		
	spriteRotDisplay.rotation_degrees = sin(Global.animationTick*0.05)*(size/2.0)+(minimum+(size/2.0))
	$VBoxContainer/RotationalLimitsSection/RotBack/RotLineDisplay3.rotation_degrees = spriteRotDisplay.rotation_degrees


func _on_speaking_pressed():
	var f = $VBoxContainer/Buttons/SpeakingWrapper/Speaking.frame
	f = (f+1) % 3
	
	$VBoxContainer/Buttons/SpeakingWrapper/Speakingaking.frame = f
	Global.heldSprite.showOnTalk = f


func _on_blinking_pressed():
	var f = $VBoxContainer/Buttons/BlinkingWrapper/Blinking.frame
	f = (f+1) % 3
	
	$VBoxContainer/Buttons/BlinkingWrapper/Blinking.frame = f
	Global.heldSprite.showOnBlink = f


func _on_trash_pressed():
	# Clean up wobble sync group membership before deleting
	if Global.heldSprite.wobbleSyncGroup != "" and WobbleSyncManager:
		WobbleSyncManager.onSpriteDeleted(Global.heldSprite.id)
	
	Global.heldSprite.queue_free()
	Global.heldSprite = null
	
	Global.spriteList.updateData()

func _on_unlink_pressed():
	if Global.heldSprite.parentId == null:
		return
	Global.unlinkSprite()
	setImage()
	

func changeRotLimit():
	$VBoxContainer/RotationalLimitsSection/RotBack/rotLimitBar.value = Global.heldSprite.rLimitMax - Global.heldSprite.rLimitMin
	$VBoxContainer/RotationalLimitsSection/RotBack/rotLimitBar.rotation_degrees = Global.heldSprite.rLimitMin + 90
	
	$VBoxContainer/RotationalLimitsSection/RotBack/RotLineDisplay.rotation_degrees = Global.heldSprite.rLimitMin
	$VBoxContainer/RotationalLimitsSection/RotBack/RotLineDisplay2.rotation_degrees = Global.heldSprite.rLimitMax
	
func setLayerButtons():
	if Global.heldSprite == null:
		return
		
	var a = Global.heldSprite.costumeLayers.duplicate()
	
	$VBoxContainer/LayersSection/HBoxContainer/Layer1Container/Layer1.frame = 1-a[0]
	$VBoxContainer/LayersSection/HBoxContainer/Layer2Container/Layer2.frame = 1-a[1]
	$VBoxContainer/LayersSection/HBoxContainer/Layer3Container/Layer3.frame = 1-a[2]
	$VBoxContainer/LayersSection/HBoxContainer/Layer4Container/Layer4.frame = 1-a[3]
	$VBoxContainer/LayersSection/HBoxContainer/Layer5Container/Layer5.frame = 1-a[4]
	$VBoxContainer/LayersSection/HBoxContainer2/Layer6Container/Layer6.frame = 1-a[5]
	$VBoxContainer/LayersSection/HBoxContainer2/Layer7Container/Layer7.frame = 1-a[6]
	$VBoxContainer/LayersSection/HBoxContainer2/Layer8Container/Layer8.frame = 1-a[7]
	$VBoxContainer/LayersSection/HBoxContainer2/Layer9Container/Layer9.frame = 1-a[8]
	$VBoxContainer/LayersSection/HBoxContainer2/Layer10Container/Layer10.frame = 1-a[9]
	
	# Update checkmarks to show current costume layer
	updateLayerCheckmarks()
	
	# Update sprite visibility for all sprites based on current costume
	var nodes = get_tree().get_nodes_in_group("saved")
	for sprite in nodes:
		if sprite.costumeLayers[Global.main.costume - 1] == 1:
			sprite.visible = true
			sprite.changeCollision(true)
		else:
			sprite.visible = false
			sprite.changeCollision(false)
	
	# Update the sprite list to reflect visibility changes
	Global.spriteList.updateAllVisible()

func updateLayerCheckmarks():
	# Hide all checkmarks first
	$VBoxContainer/LayersSection/HBoxContainer/Layer1Container/Layer1/Checkmark1.visible = false
	$VBoxContainer/LayersSection/HBoxContainer/Layer2Container/Layer2/Checkmark2.visible = false
	$VBoxContainer/LayersSection/HBoxContainer/Layer3Container/Layer3/Checkmark3.visible = false
	$VBoxContainer/LayersSection/HBoxContainer/Layer4Container/Layer4/Checkmark4.visible = false
	$VBoxContainer/LayersSection/HBoxContainer/Layer5Container/Layer5/Checkmark5.visible = false
	$VBoxContainer/LayersSection/HBoxContainer2/Layer6Container/Layer6/Checkmark6.visible = false
	$VBoxContainer/LayersSection/HBoxContainer2/Layer7Container/Layer7/Checkmark7.visible = false
	$VBoxContainer/LayersSection/HBoxContainer2/Layer8Container/Layer8/Checkmark8.visible = false
	$VBoxContainer/LayersSection/HBoxContainer2/Layer9Container/Layer9/Checkmark9.visible = false
	$VBoxContainer/LayersSection/HBoxContainer2/Layer10Container/Layer10/Checkmark10.visible = false
	
	# Show checkmark for current costume layer
	match Global.main.costume:
		1:
			$VBoxContainer/LayersSection/HBoxContainer/Layer1Container/Layer1/Checkmark1.visible = true
		2:
			$VBoxContainer/LayersSection/HBoxContainer/Layer2Container/Layer2/Checkmark2.visible = true
		3:
			$VBoxContainer/LayersSection/HBoxContainer/Layer3Container/Layer3/Checkmark3.visible = true
		4:
			$VBoxContainer/LayersSection/HBoxContainer/Layer4Container/Layer4/Checkmark4.visible = true
		5:
			$VBoxContainer/LayersSection/HBoxContainer/Layer5Container/Layer5/Checkmark5.visible = true
		6:
			$VBoxContainer/LayersSection/HBoxContainer2/Layer6Container/Layer6/Checkmark6.visible = true
		7:
			$VBoxContainer/LayersSection/HBoxContainer2/Layer7Container/Layer7/Checkmark7.visible = true
		8:
			$VBoxContainer/LayersSection/HBoxContainer2/Layer8Container/Layer8/Checkmark8.visible = true
		9:
			$VBoxContainer/LayersSection/HBoxContainer2/Layer9Container/Layer9/Checkmark9.visible = true
		10:
			$VBoxContainer/LayersSection/HBoxContainer2/Layer10Container/Layer10/Checkmark10.visible = true


func _on_layer_button_1_pressed():
	if Global.heldSprite.costumeLayers[0] == 0:
		Global.heldSprite.costumeLayers[0] = 1
	else:
		Global.heldSprite.costumeLayers[0] = 0
	setLayerButtons()


func _on_layer_button_2_pressed():
	if Global.heldSprite.costumeLayers[1] == 0:
		Global.heldSprite.costumeLayers[1] = 1
	else:
		Global.heldSprite.costumeLayers[1] = 0
	setLayerButtons()


func _on_layer_button_3_pressed():
	if Global.heldSprite.costumeLayers[2] == 0:
		Global.heldSprite.costumeLayers[2] = 1
	else:
		Global.heldSprite.costumeLayers[2] = 0
	setLayerButtons()


func _on_layer_button_4_pressed():
	if Global.heldSprite.costumeLayers[3] == 0:
		Global.heldSprite.costumeLayers[3] = 1
	else:
		Global.heldSprite.costumeLayers[3] = 0
	setLayerButtons()


func _on_layer_button_5_pressed():
	if Global.heldSprite.costumeLayers[4] == 0:
		Global.heldSprite.costumeLayers[4] = 1
	else:
		Global.heldSprite.costumeLayers[4] = 0
	setLayerButtons()

func _on_layer_button_6_pressed():
	if Global.heldSprite.costumeLayers[5] == 0:
		Global.heldSprite.costumeLayers[5] = 1
	else:
		Global.heldSprite.costumeLayers[5] = 0
	setLayerButtons()

func _on_layer_button_7_pressed():
	if Global.heldSprite.costumeLayers[6] == 0:
		Global.heldSprite.costumeLayers[6] = 1
	else:
		Global.heldSprite.costumeLayers[6] = 0
	setLayerButtons()

func _on_layer_button_8_pressed():
	if Global.heldSprite.costumeLayers[7] == 0:
		Global.heldSprite.costumeLayers[7] = 1
	else:
		Global.heldSprite.costumeLayers[7] = 0
	setLayerButtons()

func _on_layer_button_9_pressed():
	if Global.heldSprite.costumeLayers[8] == 0:
		Global.heldSprite.costumeLayers[8] = 1
	else:
		Global.heldSprite.costumeLayers[8] = 0
	setLayerButtons()

func _on_layer_button_10_pressed():
	if Global.heldSprite.costumeLayers[9] == 0:
		Global.heldSprite.costumeLayers[9] = 1
	else:
		Global.heldSprite.costumeLayers[9] = 0
	setLayerButtons()

func layerSelected():
	var newPos = Vector2.ZERO
	match Global.main.costume:
		1:
			newPos = $VBoxContainer/LayersSection/HBoxContainer/Layer1Container/Layer1.position
		2:
			newPos = $VBoxContainer/LayersSection/HBoxContainer/Layer2Container/Layer2.position
		3:
			newPos = $VBoxContainer/LayersSection/HBoxContainer/Layer3Container/Layer3.position
		4:
			newPos = $VBoxContainer/LayersSection/HBoxContainer/Layer4Container/Layer4.position
		5:
			newPos = $VBoxContainer/LayersSection/HBoxContainer/Layer5Container/Layer5.position
		6:
			newPos = $VBoxContainer/LayersSection/HBoxContainer2/Layer6Container/Layer6.position
		7:
			newPos = $VBoxContainer/LayersSection/HBoxContainer2/Layer7Container/Layer7.position
		8:
			newPos = $VBoxContainer/LayersSection/HBoxContainer2/Layer8Container/Layer8.position
		9:
			newPos = $VBoxContainer/LayersSection/HBoxContainer2/Layer9Container/Layer9.position
		10:
			newPos = $VBoxContainer/LayersSection/HBoxContainer2/Layer10Container/Layer10.position
	
	# Update selection indicator position if it exists
	var select_node = get_node_or_null("VBoxContainer/LayersSection/Select")
	if select_node:
		select_node.position = newPos


func _on_clip_linked_toggled(button_pressed):
	Global.heldSprite.setClip(button_pressed)


func _on_check_box_toggled(button_pressed):
	Global.heldSprite.ignoreBounce = button_pressed


func _on_delete_pressed():
	Global.heldSprite.toggle = "null"
	$VBoxContainer/BoxContainer/setToggle/Label.text = "toggle: \"" + Global.heldSprite.toggle +  "\""
	Global.heldSprite.makeVis()

func _on_set_toggle_pressed():
	$VBoxContainer/BoxContainer/setToggle/Label.text = "toggle: AWAITING INPUT"
	await Global.main.fatfuckingballs
	
	var keys = await Global.main.spriteVisToggles
	var key = keys[0]
	Global.heldSprite.toggle = key
	$VBoxContainer/BoxContainer/setToggle/Label.text = "toggle: \"" + Global.heldSprite.toggle +  "\""

func _on_affect_children_check_toggled(button_pressed):
	Global.heldSprite.affectChildrenOpacity = button_pressed
	Global.heldSprite.updateOpacity()

func _on_mirror_horizontal_check_toggled(button_pressed):
	Global.heldSprite.mirrorHorizontal = button_pressed

func _on_mirror_vertical_check_toggled(button_pressed):
	Global.heldSprite.mirrorVertical = button_pressed

## Set up the blend mode dropdown with all available blend modes
func setupBlendModeDropdown():
	blendModeDropdown.clear()
	var blendModeNames = BlendModeManager.get_blend_mode_names()
	for mode_name in blendModeNames:
		blendModeDropdown.add_item(mode_name)

## Handle blend mode dropdown selection
func _on_blend_mode_dropdown_item_selected(index: int):
	if Global.heldSprite != null:
		Global.heldSprite.updateBlendMode(index)
		Global.pushUpdate("Blend mode set to: " + BlendModeManager.get_blend_mode_name(index))
