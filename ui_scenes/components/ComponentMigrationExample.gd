## Example implementation showing how to replace legacy wobble controls
## with the new WobbleControlPanel component
extends Node2D

## This demonstrates the integration approach for the sprite viewer

## Legacy slider references (to be replaced)
@onready var legacy_wobble_control = $LegacyWobbleControl

## New component system
@onready var wobble_panel: WobbleControlPanel = $WobbleControlPanel
var slider_manager: SliderManager

func _ready():
	# Initialize slider management
	slider_manager = SliderManager.new(self)
	
	# Set up the wobble panel
	if wobble_panel:
		# The panel will automatically configure its sliders
		print("WobbleControlPanel initialized")
	
	# Hide legacy controls when using new system
	if legacy_wobble_control:
		legacy_wobble_control.visible = false

## Updated setImage function using new components
func setImage_new_system():
	if Global.heldSprite == null:
		return
	
	print("Setting image with new component system")
	
	# Update wobble panel with current sprite
	if wobble_panel:
		wobble_panel.set_target_sprite(Global.heldSprite)
		wobble_panel.update_from_sprite()
	
	# Update sync feedback
	updateWobbleControlStates_new_system()

## Updated wobble control states using new system
func updateWobbleControlStates_new_system():
	if Global.heldSprite == null:
		return
	
	if wobble_panel:
		wobble_panel.update_sync_feedback()

## Migration helper - gradually replace sections
func migrate_to_new_system():
	print("Migrating wobble controls to new component system...")
	
	# Step 1: Hide old controls
	if has_node("WobbleControl"):
		$WobbleControl.visible = false
	
	# Step 2: Show new panel
	if wobble_panel:
		wobble_panel.visible = true
		
	# Step 3: Update with current sprite
	if Global.heldSprite:
		setImage_new_system()
	
	print("Migration complete!")

## Demonstration of component benefits
func demonstrate_consistency():
	print("=== Component System Benefits ===")
	
	if wobble_panel:
		print("All wobble sliders have consistent:")
		print("- Visual styling")
		print("- Value formatting") 
		print("- Label positioning")
		print("- Signal handling")
		print("- Sync state feedback")
	
	print("Components are easily reusable across scenes")
	print("Centralized management through SliderManager")
	print("Type-safe with proper class inheritance")
