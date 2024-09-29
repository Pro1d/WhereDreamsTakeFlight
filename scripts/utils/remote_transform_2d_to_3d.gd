class_name RemoteTransform2DTo3D
extends Node2D

@export var _target_3d : Node3D
@export var y_offset := 0.0
@onready var _camera_3d := get_viewport().get_camera_3d() as Camera3D

func _enter_tree() -> void:
	process_physics_priority = -100

func _physics_process(_delta: float) -> void:
	_target_3d.global_position = _camera_3d.project_position(global_position, absf(_camera_3d.global_position.y)+y_offset)
	_target_3d.global_position.y += y_offset
	_target_3d.global_rotation.y = -global_rotation
