extends Node2D

@onready var editSprite = $Edit/Fancy
@onready var editButton = $Edit/Button

func _process(delta):
	var uiAnimSpeed = 8.0  # Fixed UI animation speed
	if Rect2(editButton.get_parent().position-Vector2(24,24),editButton.size).has_point(get_local_mouse_position()):
		editSprite.scale = lerp(editSprite.scale, Vector2(1.2,1.2), delta * uiAnimSpeed)
	else:
		editSprite.scale = lerp(editSprite.scale, Vector2(1.0,1.0), delta * uiAnimSpeed)
