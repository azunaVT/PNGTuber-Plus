extends Node

## Test script for wobble sync groups - run this to verify the system is working

func _ready():
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	print("=== Wobble Sync Groups Test ===")
	
	# Test creating a group
	var success = WobbleSyncManager.createGroup("TestGroup")
	print("Create group 'TestGroup': ", success)
	
	# Test getting group names
	var groups = WobbleSyncManager.getGroupNames()
	print("Available groups: ", groups)
	
	# Test group existence
	print("Group 'TestGroup' exists: ", WobbleSyncManager.hasGroup("TestGroup"))
	print("Group 'NonExistent' exists: ", WobbleSyncManager.hasGroup("NonExistent"))
	
	# Clean up test group
	WobbleSyncManager.deleteGroup("TestGroup")
	print("Deleted test group")
	
	groups = WobbleSyncManager.getGroupNames()
	print("Groups after deletion: ", groups)
	
	print("=== Test Complete ===")
