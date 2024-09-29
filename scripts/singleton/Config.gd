extends Node

#const CursorArrowIcon := preload("res://assets/images/ui/cursor_arrow2.atlastex")
#const CursorIBeamIcon := preload("res://assets/images/ui/cursor_ibeam.atlastex")
#const CursorAimIcon := preload("res://assets/images/ui/cursor_aim1.atlastex")

var MAP_SIZE := Vector2(0.25 * 2 * 1377 / 768, 0.25 * 2)
var MAP_BOUNDARIES := Rect2(-MAP_SIZE / 2, MAP_SIZE)
var PLAYER_AREA := Rect2(-MAP_SIZE / 2, Vector2(0.4, 1.0) * MAP_SIZE)

var LAYER_PLAYER := 1 << 2
var LAYER_ENEMY := 1 << 3
var LAYER_PLAYER_PROJECTILE := 1 << 4 #(ProjectSettings.get_setting("layer_names/2d_physics/player_projectile") as int)
var LAYER_ENEMY_PROJECTILE := 1 << 5 #(ProjectSettings.get_setting("layer_names/2d_physics/enemy_projectile") as int)

func _enter_tree() -> void:
	print("layers p_proj=", LAYER_PLAYER_PROJECTILE, " eproj=", LAYER_ENEMY_PROJECTILE)
#	Input.set_custom_mouse_cursor(
#		CursorArrowIcon, Input.CURSOR_ARROW, Vector2(2, 2)
#	)
#	Input.set_custom_mouse_cursor(
#		CursorIBeamIcon, Input.CURSOR_IBEAM, Vector2(16, 16)
#	)
#	Input.set_custom_mouse_cursor(
#		CursorAimIcon, Input.CURSOR_CROSS, Vector2(16, 16)
#	)
	pass
