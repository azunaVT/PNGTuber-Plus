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
	print("DEBUG: WobbleSyncManager._ready() called")
	print("DEBUG: WobbleSyncManager autoload initialized successfully")
	print("DEBUG: Initial syncGroups: ", syncGroups)
	print("DEBUG: Initial spriteGroupMembership: ", spriteGroupMembership)

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
		print("DEBUG: WobbleSyncGroup.setWobbleParameters called for group '", name, "' with ", memberSprites.size(), " members")
		print("DEBUG: Member sprite IDs: ", memberSprites)
		xFrq = x_frq
		xAmp = x_amp
		yFrq = y_frq
		yAmp = y_amp
		rFrq = r_frq
		rAmp = r_amp
		
		# Update all member sprites using the manager reference
		var sprites = manager_ref.get_tree().get_nodes_in_group("saved")
		print("DEBUG: Found ", sprites.size(), " total sprites in 'saved' group")
		
		var updated_count = 0
		for sprite in sprites:
			print("DEBUG: Checking sprite ID ", sprite.id, " (type: ", typeof(sprite.id), ") against member list")
			if sprite.id in memberSprites:
				print("DEBUG: Updating sprite ID ", sprite.id, " with new wobble values (no scaling - values stored as-is)")
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
			else:
				print("DEBUG: Sprite ID ", sprite.id, " not in member list")
		
		print("DEBUG: Updated ", updated_count, " sprites in group '", name, "'")
	
	## Add sprite to this group
	func addSprite(sprite_id):  # Remove type constraint to handle float IDs
		print("DEBUG: WobbleSyncGroup.addSprite called with sprite_id: ", sprite_id, " (type: ", typeof(sprite_id), ")")
		if sprite_id not in memberSprites:
			memberSprites.append(sprite_id)
			print("DEBUG: Added sprite to memberSprites. Current members: ", memberSprites)
		else:
			print("DEBUG: Sprite already in memberSprites")
	
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
	print("DEBUG: addSpriteToGroup called with sprite_id: ", sprite_id, " (type: ", typeof(sprite_id), "), group: '", group_name, "'")
	
	if not syncGroups.has(group_name):
		print("DEBUG: Group '", group_name, "' not found")
		return false
	
	# Remove sprite from any existing group first
	removeSpriteFromAllGroups(sprite_id)
	
	var group = syncGroups[group_name]
	group.addSprite(sprite_id)
	spriteGroupMembership[sprite_id] = group_name
	print("DEBUG: Added sprite ", sprite_id, " to group '", group_name, "'. Group now has ", group.memberSprites.size(), " members")
	
	# Sync the sprite's wobble parameters to the group
	var sprite = getSpriteById(sprite_id)
	if sprite:
		print("DEBUG: Found sprite object, syncing wobble parameters to group values")
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
	print("DEBUG: removeSpriteFromGroup called for sprite ID: ", sprite_id, " (type: ", typeof(sprite_id), "), group: '", group_name, "'")
	if not syncGroups.has(group_name):
		print("DEBUG: Group '", group_name, "' not found")
		return
	
	var group = syncGroups[group_name]
	print("DEBUG: Group before removal has ", group.memberSprites.size(), " members: ", group.memberSprites)
	group.removeSprite(sprite_id)
	spriteGroupMembership.erase(sprite_id)
	print("DEBUG: Group after removal has ", group.memberSprites.size(), " members: ", group.memberSprites)
	
	# Clear the sprite's sync group reference
	var sprite = getSpriteById(sprite_id)
	if sprite:
		print("DEBUG: Clearing sprite's wobbleSyncGroup property")
		sprite.wobbleSyncGroup = ""
	else:
		print("DEBUG: Could not find sprite object for ID: ", sprite_id)
	
	sprite_left_group.emit(sprite_id, group_name)
	
	# Auto-delete empty groups
	if group.isEmpty():
		deleteGroup(group_name)
	else:
		Global.pushUpdate("Removed sprite from wobble sync group: " + group_name)

## Remove sprite from all groups
func removeSpriteFromAllGroups(sprite_id):  # Remove type constraint
	print("DEBUG: removeSpriteFromAllGroups called for sprite ID: ", sprite_id)
	if spriteGroupMembership.has(sprite_id):
		var group_name = spriteGroupMembership[sprite_id]
		print("DEBUG: Found sprite in group '", group_name, "', removing...")
		removeSpriteFromGroup(sprite_id, group_name)
	else:
		print("DEBUG: Sprite not found in any group membership")

## Update wobble parameters for a group
func updateGroupWobble(group_name: String, x_frq: float, x_amp: float, y_frq: float, y_amp: float, r_frq: float, r_amp: float):
	print("DEBUG: updateGroupWobble called for group '", group_name, "' with values - xFrq:", x_frq, " xAmp:", x_amp, " yFrq:", y_frq, " yAmp:", y_amp, " rFrq:", r_frq, " rAmp:", r_amp)
	
	if not syncGroups.has(group_name):
		print("DEBUG: Group '", group_name, "' not found in syncGroups!")
		print("DEBUG: Available groups: ", syncGroups.keys())
		print("DEBUG: This suggests the avatar's wobble sync groups were never loaded from the save file!")
		print("DEBUG: Either the save file doesn't contain wobbleSyncGroups, or the loading process didn't run.")
		return
	
	var group = syncGroups[group_name]
	print("DEBUG: Found group, calling setWobbleParameters on group with ", group.memberSprites.size(), " members")
	group.setWobbleParameters(x_frq, x_amp, y_frq, y_amp, r_frq, r_amp, self)

## Get sprite's current group name
func getSpriteGroupName(sprite_id: int) -> String:
	return spriteGroupMembership.get(sprite_id, "")

## Get all group names
func getGroupNames() -> Array:
	print("DEBUG: getGroupNames called. syncGroups has ", syncGroups.size(), " groups: ", syncGroups.keys())
	print("DEBUG: getGroupNames - syncGroups reference: ", syncGroups)
	print("DEBUG: getGroupNames - self reference: ", self)
	return syncGroups.keys()

## Test function to manually load wobble sync groups
func testManualLoad():
	print("DEBUG: testManualLoad called - creating test data...")
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
	print("DEBUG: Calling loadSaveData with test data...")
	await loadSaveData(test_data)
	print("DEBUG: testManualLoad completed. syncGroups now has: ", syncGroups.size(), " groups")

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
	print("DEBUG: ========================")
	print("DEBUG: WobbleSyncManager.loadSaveData called with save_data: ", save_data)
	print("DEBUG: save_data type: ", typeof(save_data))
	print("DEBUG: save_data.keys(): ", save_data.keys())
	print("DEBUG: save_data.size(): ", save_data.size())
	print("DEBUG: self reference: ", self)
	print("DEBUG: syncGroups before clear: ", syncGroups)
	
	# Check if save_data is valid
	if save_data == null or typeof(save_data) != TYPE_DICTIONARY:
		print("DEBUG: ERROR - Invalid save_data provided")
		return
	
	if save_data.size() == 0:
		print("DEBUG: WARNING - Empty save_data provided")
		return
	
	# Clear existing groups
	print("DEBUG: Clearing existing syncGroups (had ", syncGroups.size(), " groups)")
	syncGroups.clear()
	spriteGroupMembership.clear()
	print("DEBUG: Cleared existing data. syncGroups now has ", syncGroups.size(), " groups")
	
	# Load groups from save data
	var loaded_groups = 0
	print("DEBUG: Starting group loading loop...")
	for group_name in save_data.keys():
		print("DEBUG: ---- Processing group '", group_name, "' (attempt ", loaded_groups + 1, ") ----")
		var group_data = save_data[group_name]
		print("DEBUG: Group data type: ", typeof(group_data))
		print("DEBUG: Group data: ", group_data)
		
		if typeof(group_data) == TYPE_DICTIONARY:
			print("DEBUG: Creating WobbleSyncGroup instance...")
			var group = WobbleSyncGroup.new(group_name)
			print("DEBUG: Created new WobbleSyncGroup instance for '", group_name, "'")
			print("DEBUG: Calling fromSaveData...")
			group.fromSaveData(group_data)
			print("DEBUG: Called fromSaveData on group '", group_name, "'")
			print("DEBUG: Adding to syncGroups dictionary...")
			syncGroups[group_name] = group
			loaded_groups += 1
			print("DEBUG: Added group '", group_name, "' to syncGroups. Total groups now: ", syncGroups.size())
			print("DEBUG: syncGroups.keys() now: ", syncGroups.keys())
			print("DEBUG: Group memberSprites: ", group.memberSprites)
			
			# Update sprite group membership
			print("DEBUG: Updating sprite group membership...")
			for sprite_id in group.memberSprites:
				spriteGroupMembership[sprite_id] = group_name
				print("DEBUG: Added sprite ", sprite_id, " to spriteGroupMembership for group '", group_name, "'")
			print("DEBUG: ---- Finished processing group '", group_name, "' ----")
		else:
			print("DEBUG: ERROR - Group data for '", group_name, "' is not a Dictionary, skipping")
	
	print("DEBUG: ========================")
	print("DEBUG: GROUP LOADING COMPLETE")
	print("DEBUG: Loaded ", loaded_groups, " groups total")
	print("DEBUG: Final syncGroups after loading: ", syncGroups.keys())
	print("DEBUG: Final syncGroups size: ", syncGroups.size())
	print("DEBUG: Final syncGroups contents: ", syncGroups)
	print("DEBUG: Final spriteGroupMembership: ", spriteGroupMembership)
	print("DEBUG: ========================")
	
	# If no groups were loaded, clear any orphaned group references on sprites
	if syncGroups.size() == 0:
		print("DEBUG: No groups loaded, clearing orphaned sprite group references")
		var sprites = get_tree().get_nodes_in_group("saved")
		for sprite in sprites:
			if sprite.wobbleSyncGroup != "":
				print("DEBUG: Clearing orphaned group reference '", sprite.wobbleSyncGroup, "' from sprite ID ", sprite.id)
				sprite.wobbleSyncGroup = ""
	else:
		print("DEBUG: Groups loaded successfully, syncing sprite parameters...")
		# Apply wobble parameters to sprites with better timing
		await get_tree().process_frame  # Wait for sprites to be loaded
		await get_tree().process_frame  # Extra frame to ensure everything is ready
		
		for group_name in syncGroups.keys():
			var group = syncGroups[group_name]
			print("DEBUG: Syncing parameters for group '", group_name, "' with ", group.memberSprites.size(), " members")
			for sprite_id in group.memberSprites:
				var sprite = getSpriteById(sprite_id)
				if sprite:
					print("DEBUG: Syncing sprite ID ", sprite_id, " to group '", group_name, "'")
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
					print("DEBUG: ERROR - Could not find sprite with ID ", sprite_id)
	
	print("DEBUG: ========================")
	print("DEBUG: loadSaveData FUNCTION COMPLETE")
	print("DEBUG: Final verification - syncGroups has ", syncGroups.size(), " groups: ", syncGroups.keys())
	print("DEBUG: ========================")

## Called when a sprite is deleted to clean up references
func onSpriteDeleted(sprite_id):  # Remove type constraint
	removeSpriteFromAllGroups(sprite_id)

## Debug function to check data consistency
func checkDataConsistency():
	print("=== WOBBLE SYNC DATA CONSISTENCY CHECK ===")
	
	# Check each group's member sprites
	for group_name in syncGroups.keys():
		var group = syncGroups[group_name]
		print("Group '", group_name, "' has ", group.memberSprites.size(), " members: ", group.memberSprites)
		
		for sprite_id in group.memberSprites:
			# Check if sprite exists
			var sprite = getSpriteById(sprite_id)
			if sprite == null:
				print("  ERROR: Sprite ID ", sprite_id, " in group but sprite object not found!")
			else:
				# Check if sprite's wobbleSyncGroup matches
				if sprite.wobbleSyncGroup != group_name:
					print("  ERROR: Sprite ID ", sprite_id, " in group '", group_name, "' but sprite.wobbleSyncGroup = '", sprite.wobbleSyncGroup, "'")
				else:
					print("  OK: Sprite ID ", sprite_id, " consistent")
			
			# Check if membership mapping is correct
			if not spriteGroupMembership.has(sprite_id) or spriteGroupMembership[sprite_id] != group_name:
				print("  ERROR: Sprite ID ", sprite_id, " in group but spriteGroupMembership is wrong!")
	
	# Check membership mapping for orphaned entries
	for sprite_id in spriteGroupMembership.keys():
		var group_name = spriteGroupMembership[sprite_id]
		if not syncGroups.has(group_name):
			print("ERROR: Sprite ID ", sprite_id, " mapped to non-existent group '", group_name, "'")
		else:
			var group = syncGroups[group_name]
			if sprite_id not in group.memberSprites:
				print("ERROR: Sprite ID ", sprite_id, " mapped to group '", group_name, "' but not in group's member list")
	
	print("=== END CONSISTENCY CHECK ===")
