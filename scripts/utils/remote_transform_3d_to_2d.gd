class_name RemoteTransform3DTo2D
extends Node3D

@export var _target_2d : Node2D
@onready var _camera_3d := get_viewport().get_camera_3d() as Camera3D

func _enter_tree() -> void:
	process_physics_priority = -100

func _physics_process(_delta: float) -> void:
	_target_2d.global_position = _camera_3d.unproject_position(global_position)
	#var ahead := _camera_3d.unproject_position(global_position + global_transform.basis.x * 0.05)
	_target_2d.global_rotation = -global_rotation.y  # (ahead - _target_2d.global_position).angle()
