extends Node

#const CursorArrowIcon := preload("res://assets/images/ui/cursor_arrow2.atlastex")
#const CursorIBeamIcon := preload("res://assets/images/ui/cursor_ibeam.atlastex")
#const CursorAimIcon := preload("res://assets/images/ui/cursor_aim1.atlastex")

var MAP_SIZE := Vector2(0.25 * 2 * 1377 / 768, 0.25 * 2)
var MAP_BOUNDARIES := Rect2(-MAP_SIZE / 2, MAP_SIZE)
var PLAYER_AREA := Rect2(-MAP_SIZE / 2, Vector2(0.5, 1.0) * MAP_SIZE)

var LAYER_PLAYER := 1 << 1
var LAYER_ENEMY := 1 << 2
var LAYER_PLAYER_PROJECTILE := 1 << 3 #(ProjectSettings.get_setting("layer_names/2d_physics/player_projectile") as String)
var LAYER_ENEMY_PROJECTILE := 1 << 4 #(ProjectSettings.get_setting("layer_names/2d_physics/enemy_projectile") as String)

const curve_width_resources : Array[Resource] = [
	preload("res://resources/materials/curve_width_1.tres"),
	preload("res://resources/materials/curve_width_2.tres"),
	preload("res://resources/materials/curve_width_3.tres"),
	preload("res://resources/materials/curve_width_4.tres"),
]

var player_node : PlayerPlane
var root_2d : Node2D
var root_3d : Node3D
var camera_3d : Camera3D
func _enter_tree() -> void:
	camera_3d = get_viewport().get_camera_3d()
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
