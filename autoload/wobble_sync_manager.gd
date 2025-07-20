extends Node

## WobbleSyncGroupManager - Manages synchronized wobble groups for sprites
## Follows class-based OOP pattern as requested

var syncGroups: Dictionary = {}  # groupName: WobbleSyncGroup
var spriteGroupMembership: Dictionary = {}  # spriteId: groupName

signal group_created(group_name: String)
signal group_deleted(group_name: String)
signal sprite_joined_group(sprite_id: int, group_name: String)
signal sprite_left_group(sprite_id: int, group_name: String)

func _ready():
	# Manager initialization complete
	pass

class WobbleSyncGroup:
	var name: String
	var xFrq: float = 0.0
	var xAmp: float = 0.0
	var yFrq: float = 0.0
	var yAmp: float = 0.0
	var rFrq: float = 0.0
	var rAmp: float = 0.0
	var memberSprites: Array = []
	
	func _init(group_name: String):
		name = group_name
	
	## Set wobble parameters for the entire group
	func setWobbleParameters(x_frq: float, x_amp: float, y_frq: float, y_amp: float, r_frq: float, r_amp: float, manager_ref):
		xFrq = x_frq
		xAmp = x_amp
		yFrq = y_frq
		yAmp = y_amp
		rFrq = r_frq
		rAmp = r_amp
		
		# Update all member sprites using the manager reference
		var sprites = manager_ref.get_tree().get_nodes_in_group("saved")
		
		var updated_count = 0
		for sprite in sprites:
			if sprite.id in memberSprites:
				# Preserve the sprite's group membership
				var current_group = sprite.wobbleSyncGroup
				sprite.xFrq = xFrq
				sprite.xAmp = xAmp
				sprite.yFrq = yFrq
				sprite.yAmp = yAmp
				sprite.rFrq = rFrq
				sprite.rAmp = rAmp
				# Restore group membership in case it got cleared
				sprite.wobbleSyncGroup = current_group
				updated_count += 1
	
	## Add sprite to this group
	func addSprite(sprite_id):  # Remove type constraint to handle float IDs
		if sprite_id not in memberSprites:
			memberSprites.append(sprite_id)
		else:
			pass  # Sprite already in group
	
	## Remove sprite from this group
	func removeSprite(sprite_id):  # Remove type constraint
		memberSprites.erase(sprite_id)
	
	## Check if group is empty
	func isEmpty() -> bool:
		return memberSprites.size() == 0
	
	## Get group data for saving
	func toSaveData() -> Dictionary:
		return {
			"name": name,
			"xFrq": xFrq,
			"xAmp": xAmp,
			"yFrq": yFrq,
			"yAmp": yAmp,
			"rFrq": rFrq,
			"rAmp": rAmp,
			"memberSprites": memberSprites
		}
	
	## Load group data from save
	func fromSaveData(data: Dictionary):
		name = data.get("name", "")
		xFrq = data.get("xFrq", 0.0)
		xAmp = data.get("xAmp", 0.0)
		yFrq = data.get("yFrq", 0.0)
		yAmp = data.get("yAmp", 0.0)
		rFrq = data.get("rFrq", 0.0)
		rAmp = data.get("rAmp", 0.0)
		memberSprites = data.get("memberSprites", [])

## Create a new wobble sync group
func createGroup(group_name: String, sprite_id = -1) -> bool:  # Remove type constraint
	if group_name.strip_edges() == "" or syncGroups.has(group_name):
		return false
	
	var group = WobbleSyncGroup.new(group_name)
	syncGroups[group_name] = group
	
	# If a sprite ID is provided, add it and copy its wobble values
	if sprite_id != -1:
		var sprite = getSpriteById(sprite_id)
		if sprite:
			# Store the sprite's raw wobble values directly
			group.setWobbleParameters(sprite.xFrq, sprite.xAmp, sprite.yFrq, sprite.yAmp, sprite.rFrq, sprite.rAmp, self)
			addSpriteToGroup(sprite_id, group_name)
	
	group_created.emit(group_name)
	Global.pushUpdate("Created wobble sync group: " + group_name)
	return true

## Delete a wobble sync group
func deleteGroup(group_name: String):
	if not syncGroups.has(group_name):
		return
	
	var group = syncGroups[group_name]
	
	# Remove all sprites from the group
	for sprite_id in group.memberSprites.duplicate():
		removeSpriteFromGroup(sprite_id, group_name)
	
	syncGroups.erase(group_name)
	group_deleted.emit(group_name)
	Global.pushUpdate("Deleted wobble sync group: " + group_name)

## Add sprite to a group
func addSpriteToGroup(sprite_id, group_name: String) -> bool:  # Remove type constraint
	
	if not syncGroups.has(group_name):
		return false
	
	# Remove sprite from any existing group first
	removeSpriteFromAllGroups(sprite_id)
	
	var group = syncGroups[group_name]
	group.addSprite(sprite_id)
	spriteGroupMembership[sprite_id] = group_name
	
	# Sync the sprite's wobble parameters to the group
	var sprite = getSpriteById(sprite_id)
	if sprite:
		sprite.wobbleSyncGroup = group_name
		sprite.xFrq = group.xFrq
		sprite.xAmp = group.xAmp
		sprite.yFrq = group.yFrq
		sprite.yAmp = group.yAmp
		sprite.rFrq = group.rFrq
		sprite.rAmp = group.rAmp
	
	sprite_joined_group.emit(sprite_id, group_name)
	Global.pushUpdate("Added sprite to wobble sync group: " + group_name)
	return true

## Remove sprite from a specific group
func removeSpriteFromGroup(sprite_id, group_name: String):  # Remove type constraint
	if not syncGroups.has(group_name):
		return
	
	var group = syncGroups[group_name]
	group.removeSprite(sprite_id)
	spriteGroupMembership.erase(sprite_id)
	
	# Clear the sprite's sync group reference
	var sprite = getSpriteById(sprite_id)
	if sprite:
		sprite.wobbleSyncGroup = ""
	else:
		pass  # Sprite not found
	
	sprite_left_group.emit(sprite_id, group_name)
	
	# Auto-delete empty groups
	if group.isEmpty():
		deleteGroup(group_name)
	else:
		Global.pushUpdate("Removed sprite from wobble sync group: " + group_name)

## Remove sprite from all groups
func removeSpriteFromAllGroups(sprite_id):  # Remove type constraint
	if spriteGroupMembership.has(sprite_id):
		var group_name = spriteGroupMembership[sprite_id]
		removeSpriteFromGroup(sprite_id, group_name)
	else:
		pass  # Sprite not in any group

## Update wobble parameters for a group
func updateGroupWobble(group_name: String, x_frq: float, x_amp: float, y_frq: float, y_amp: float, r_frq: float, r_amp: float):
	
	if not syncGroups.has(group_name):
		return
	
	var group = syncGroups[group_name]
	group.setWobbleParameters(x_frq, x_amp, y_frq, y_amp, r_frq, r_amp, self)

## Get sprite's current group name
func getSpriteGroupName(sprite_id: int) -> String:
	return spriteGroupMembership.get(sprite_id, "")

## Get all group names
func getGroupNames() -> Array:
	return syncGroups.keys()

## Test function to manually load wobble sync groups
func testManualLoad():
	var test_data = {
		"ears": {
			"name": "ears",
			"xFrq": 0.0,
			"xAmp": 0.0,
			"yFrq": 0.019,
			"yAmp": 3.0,
			"rFrq": 0.399,
			"rAmp": 47.0,
			"memberSprites": [3291286625.0]
		}
	}
	await loadSaveData(test_data)

## Check if a group exists
func hasGroup(group_name: String) -> bool:
	return syncGroups.has(group_name)

## Get sprite by ID
func getSpriteById(sprite_id):  # Remove type constraint to handle float IDs
	var sprites = get_tree().get_nodes_in_group("saved")
	for sprite in sprites:
		if sprite.id == sprite_id:
			return sprite
	return null

## Clean up orphaned sprites (sprites that no longer exist)
func cleanupOrphanedSprites():
	var existing_sprite_ids = []
	var sprites = get_tree().get_nodes_in_group("saved")
	for sprite in sprites:
		existing_sprite_ids.append(sprite.id)
	
	# Check each group for orphaned sprite IDs
	for group_name in syncGroups.keys():
		var group = syncGroups[group_name]
		var orphaned_ids = []
		
		for sprite_id in group.memberSprites:
			if sprite_id not in existing_sprite_ids:
				orphaned_ids.append(sprite_id)
		
		# Remove orphaned IDs
		for orphaned_id in orphaned_ids:
			group.removeSprite(orphaned_id)
			spriteGroupMembership.erase(orphaned_id)
		
		# Delete empty groups
		if group.isEmpty():
			deleteGroup(group_name)

## Get save data for all groups
func getSaveData() -> Dictionary:
	var save_data = {}
	for group_name in syncGroups.keys():
		var group = syncGroups[group_name]
		save_data[group_name] = group.toSaveData()
	return save_data

## Load save data for all groups
func loadSaveData(save_data: Dictionary):
	
	# Check if save_data is valid
	if save_data == null or typeof(save_data) != TYPE_DICTIONARY:
		return
	
	if save_data.size() == 0:
		return
	
	# Clear existing groups
	syncGroups.clear()
	spriteGroupMembership.clear()
	
	# Load groups from save data
	var loaded_groups = 0
	for group_name in save_data.keys():
		var group_data = save_data[group_name]
		
		if typeof(group_data) == TYPE_DICTIONARY:
			var group = WobbleSyncGroup.new(group_name)
			group.fromSaveData(group_data)
			syncGroups[group_name] = group
			loaded_groups += 1
			
			# Update sprite group membership
			for sprite_id in group.memberSprites:
				spriteGroupMembership[sprite_id] = group_name
		else:
			pass  # Invalid group data
	
	
	# If no groups were loaded, clear any orphaned group references on sprites
	if syncGroups.size() == 0:
		var sprites = get_tree().get_nodes_in_group("saved")
		for sprite in sprites:
			if sprite.wobbleSyncGroup != "":
				sprite.wobbleSyncGroup = ""
	else:
		# Apply wobble parameters to sprites with better timing
		await get_tree().process_frame  # Wait for sprites to be loaded
		await get_tree().process_frame  # Extra frame to ensure everything is ready
		
		for group_name in syncGroups.keys():
			var group = syncGroups[group_name]
			for sprite_id in group.memberSprites:
				var sprite = getSpriteById(sprite_id)
				if sprite:
					sprite.wobbleSyncGroup = group_name
					sprite.xFrq = group.xFrq
					sprite.xAmp = group.xAmp
					sprite.yFrq = group.yFrq
					sprite.yAmp = group.yAmp
					sprite.rFrq = group.rFrq
					sprite.rAmp = group.rAmp
					# Force a complete opacity update after modifying sprite properties
					if sprite.has_method("updateOpacity"):
						sprite.updateOpacity()
					if sprite.has_method("updateShaderOpacity"):
						sprite.updateShaderOpacity()
				else:
					pass  # Sprite not found
	

## Called when a sprite is deleted to clean up references
func onSpriteDeleted(sprite_id):  # Remove type constraint
	removeSpriteFromAllGroups(sprite_id)
