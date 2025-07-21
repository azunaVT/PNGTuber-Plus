extends NinePatchRect

@onready var spritePreview = $SpritePreview/Sprite2D
@onready var outline = $Selected
@onready var fade = $Fade
@onready var button = $Button
@onready var label = $Label

var sprite = null
var parent = null
var spritePath = ""

var indent = 0
var childrenTags = []
var parentTag = null

## Context menu for right-click actions
var context_menu: PopupMenu = null
## Line edit for renaming
var rename_edit: LineEdit = null
## Track if we're currently in rename mode
var is_renaming: bool = false

func _ready():
	# Use displayName if available, otherwise fallback to path
	var display_text = ""
	if sprite.displayName != "":
		display_text = sprite.displayName
	else:
		var count = spritePath.get_slice_count("/") - 1
		display_text = spritePath.get_slice("/",count)
	
	label.text = display_text
	$Line2D.visible = false
	
	spritePreview.texture = sprite.sprite.texture
	
	var displaySize = sprite.imageData.get_size().y
	spritePreview.scale = Vector2(1,1) * (60.0/displaySize)
	spritePreview.offset = sprite.sprite.offset
	
	# Set up right-click detection
	button.gui_input.connect(_on_button_gui_input)
	
	# Create context menu
	_setup_context_menu()

## Set up the right-click context menu
func _setup_context_menu():
	context_menu = PopupMenu.new()
	add_child(context_menu)
	
	# Add rename option
	context_menu.add_item("Rename", 0)
	context_menu.id_pressed.connect(_on_context_menu_selected)
	
	# Wait for menu to be ready, then adjust size
	context_menu.ready.connect(_adjust_menu_size)

## Adjust the context menu size to be more compact
func _adjust_menu_size():
	if context_menu:
		# Let the menu calculate its natural size first
		await get_tree().process_frame
		context_menu.reset_size()  # Reset to content-based size

## Handle GUI input events on the button
func _on_button_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Show context menu at cursor position
			var global_pos = get_global_mouse_position()
			context_menu.position = Vector2i(global_pos)
			context_menu.popup()

## Handle context menu selections
func _on_context_menu_selected(id: int):
	match id:
		0: # Rename
			_start_rename()

## Start the rename process
func _start_rename():
	if is_renaming:
		return
	
	is_renaming = true
	
	# Create line edit for renaming
	rename_edit = LineEdit.new()
	add_child(rename_edit)
	
	# Position and size the line edit over the label
	rename_edit.position = label.position
	rename_edit.size = label.size
	rename_edit.text = label.text
	
	# Hide the original label
	label.visible = false
	
	# Focus the line edit and select all text
	rename_edit.grab_focus()
	rename_edit.select_all()
	
	# Connect signals
	rename_edit.text_submitted.connect(_on_rename_submitted)
	rename_edit.focus_exited.connect(_on_rename_focus_lost)

## Handle rename submission (Enter key)
func _on_rename_submitted(new_name: String):
	if rename_edit != null:
		_finish_rename(new_name)

## Handle losing focus (clicking elsewhere)
func _on_rename_focus_lost():
	if rename_edit != null:
		_finish_rename(rename_edit.text)

## Finish the rename process
func _finish_rename(new_name: String):
	if not is_renaming:
		return
	
	is_renaming = false
	
	# Clean up the line edit
	if rename_edit:
		rename_edit.queue_free()
		rename_edit = null
	
	# Show the label again
	label.visible = true
	
	# Validate and apply the new name
	new_name = new_name.strip_edges()
	if new_name != "" and new_name != label.text:
		_apply_rename(new_name)

## Apply the rename to the sprite
func _apply_rename(new_name: String):
	# Update the display name (without file extension)
	label.text = new_name
	sprite.displayName = new_name  # Store display name separately
	
	# Update the global sprite list
	Global.spriteList.updateData()
	
	# Show feedback to user
	Global.pushUpdate("Renamed sprite to: " + new_name)
	
	
func updateChildren():
	for child in childrenTags:
		child.indent = indent + 1

func updateIndent():
	var push = (indent * 12) + 13
	
	$Label.size.x -= push
	$Label.position.x += push
	
	$Line2D.points[2]=Vector2(push-3,0)
	var xLine = (indent * 8)-6
	var yLine = -14
	
	for i in range(64):
		var previousIndent = get_parent().get_child(get_index()-1-i).indent
		if previousIndent <= indent:
			yLine = -43 * (i+1)
			if previousIndent == 0:
				yLine = -14
			break
	
	$Line2D.points[0]=Vector2(xLine,yLine)
	$Line2D.points[1]=Vector2(xLine,0)
	
	$Line2D.visible = true

func _on_button_pressed():
	if Global.heldSprite != null and Global.reparentMode:
		Global.linkSprite(Global.heldSprite,sprite)
		Global.chain.enable(false)
	
	Global.heldSprite = sprite
	Global.spriteEdit.setImage()
	
	var count = sprite.path.get_slice_count("/") - 1
	var i1 = sprite.path.get_slice("/",count)
	Global.pushUpdate("Selected sprite \"" + i1 + "\"" + ".")
	
	sprite.set_physics_process(true)

func _process(delta):
	outline.visible = sprite == Global.heldSprite
	
func updateVis():
	fade.visible = !sprite.visible
