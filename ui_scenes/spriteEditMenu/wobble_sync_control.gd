extends Control

## WobbleSyncControl - UI component for managing wobble sync groups
## Designed to integrate into the sprite editor panel

@onready var groupDropdown = $VBoxContainer/GroupRow/GroupDropdown
@onready var syncIndicator = $VBoxContainer/SyncIndicator
@onready var createGroupDialog = $CreateGroupDialog
@onready var groupNameInput = $CreateGroupDialog/VBoxContainer/LineEdit

var currentSprite = null
var updating_dropdown = false  # Flag to prevent recursive calls

signal group_changed(sprite_id: int, group_name: String)

func _ready():
	# Wait for autoload to be ready
	await get_tree().process_frame
	
	# Connect UI signals - no add button to connect
	groupDropdown.item_selected.connect(_on_group_dropdown_selected)
	createGroupDialog.confirmed.connect(_on_create_group_confirmed)
	createGroupDialog.canceled.connect(_on_create_group_cancelled)
	
	# Connect to wobble sync manager signals
	if WobbleSyncManager:
		WobbleSyncManager.group_created.connect(_on_group_created)
		WobbleSyncManager.group_deleted.connect(_on_group_deleted)
	
	# Setup create group dialog
	createGroupDialog.title = "Create Wobble Sync Group"
	createGroupDialog.size = Vector2(300, 150)
	createGroupDialog.unresizable = false
	createGroupDialog.transient = true  # Prevent click-through
	createGroupDialog.exclusive = true  # Make modal
	createGroupDialog.popup_window = false  # Keep as embedded dialog
	createGroupDialog.always_on_top = true
	
	updateUI()

## Update the UI based on current sprite selection
func updateUI():
	updateGroupDropdown()
	updateSyncIndicator()

## Update the group dropdown with available options
func updateGroupDropdown():
	updating_dropdown = true  # Prevent recursive calls
	
	groupDropdown.clear()
	
	# Add "None" option
	groupDropdown.add_item("None")
	
	# Add existing groups
	if WobbleSyncManager:
		var groups = WobbleSyncManager.getGroupNames()
		for group_name in groups:
			groupDropdown.add_item(group_name)
	else:
		pass  # WobbleSyncManager not available
	
	# Add "Create New..." option
	groupDropdown.add_separator()
	groupDropdown.add_item("Create New...")
	
	# Select current group if sprite is synced
	if currentSprite != null and currentSprite.wobbleSyncGroup != "":
		var group_index = -1
		for i in range(groupDropdown.get_item_count()):
			if groupDropdown.get_item_text(i) == currentSprite.wobbleSyncGroup:
				group_index = i
				break
		
		if group_index != -1:
			groupDropdown.selected = group_index
		else:
			groupDropdown.selected = 0  # Select "None"
	else:
		groupDropdown.selected = 0  # Select "None"
	
	updating_dropdown = false

## Update the sync indicator
func updateSyncIndicator():
	if currentSprite == null:
		syncIndicator.visible = false
		return
	
	if currentSprite.isSynced():
		syncIndicator.visible = true
		syncIndicator.text = "⚡ Synced to \"" + currentSprite.wobbleSyncGroup + "\""
	else:
		syncIndicator.visible = false

## Set the current sprite to manage
func setSprite(sprite):
	currentSprite = sprite
	if currentSprite:
		pass  # Sprite is valid
	updateUI()

## Get available groups for the dropdown (excluding "None" and "Create New...")
func getAvailableGroups() -> Array:
	var groups = []
	for i in range(1, groupDropdown.get_item_count() - 2):  # Skip "None" and "Create New..."
		groups.append(groupDropdown.get_item_text(i))
	return groups

## Handle group dropdown selection
func _on_group_dropdown_selected(index: int):
	if currentSprite == null or updating_dropdown:
		return
	
	var selected_text = groupDropdown.get_item_text(index)
	
	match selected_text:
		"None":
			# Remove sprite from any group
			if currentSprite.wobbleSyncGroup != "" and WobbleSyncManager:
				WobbleSyncManager.removeSpriteFromAllGroups(currentSprite.id)
				Global.pushUpdate("Removed sprite from wobble sync group")
		
		"Create New...":
			# Show create group dialog
			groupNameInput.text = ""
			groupNameInput.placeholder_text = "Enter group name..."
			createGroupDialog.popup_centered_clamped(Vector2i(300, 150))
			groupNameInput.grab_focus()
			# Reset dropdown to current selection
			updateGroupDropdown()
		
		_:
			# Join selected group
			if WobbleSyncManager and WobbleSyncManager.hasGroup(selected_text):
				WobbleSyncManager.addSpriteToGroup(currentSprite.id, selected_text)
				# Refresh sprite editor to show updated wobble values
				if Global.spriteEdit:
					Global.spriteEdit.setImage()
			else:
				pass  # Group doesn't exist

	updateSyncIndicator()

## Handle create group dialog confirmation
func _on_create_group_confirmed():
	var group_name = groupNameInput.text.strip_edges()
	
	if group_name == "":
		Global.pushUpdate("Group name cannot be empty")
		return
	
	if WobbleSyncManager and WobbleSyncManager.hasGroup(group_name):
		Global.pushUpdate("Group \"" + group_name + "\" already exists")
		return
	
	# Create group with current sprite
	if currentSprite != null and WobbleSyncManager:
		if WobbleSyncManager.createGroup(group_name, currentSprite.id):
			createGroupDialog.hide()
			updateUI()
			# Refresh sprite editor to show sync status
			if Global.spriteEdit:
				Global.spriteEdit.setImage()
		else:
			pass  # Failed to create group
	else:
		pass  # No sprite or WobbleSyncManager not available

## Handle create group dialog cancellation
func _on_create_group_cancelled():
	createGroupDialog.hide()
	updateGroupDropdown()  # Reset dropdown to current selection

## Handle group creation signal from manager
func _on_group_created(group_name: String):
	updateGroupDropdown()

## Handle group deletion signal from manager
func _on_group_deleted(group_name: String):
	updateGroupDropdown()
	updateSyncIndicator()

## Check if current sprite can have wobble syncing applied
func canSync() -> bool:
	return currentSprite != null

## Force refresh the UI - useful after loading saves
func forceRefresh():
	updateUI()
