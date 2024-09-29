class_name RemoteTransform3DTo2D
extends Node3D

@export var _target_2d : Node2D
@export var offset : Vector3
@onready var _camera_3d := get_viewport().get_camera_3d() as Camera3D

func _enter_tree() -> void:
	process_physics_priority = -100

func _ready() -> void:
	_target_2d.top_level = true

func _physics_process(_delta: float) -> void:
	_target_2d.global_position = _camera_3d.unproject_position(global_position+offset)
	#var ahead := _camera_3d.unproject_position(global_position + global_transform.basis.x * 0.05)
	_target_2d.global_rotation = -global_rotation.y  # (ahead - _target_2d.global_position).angle()

static func unproject(from: Node3D, o: Vector3, to: Node2D) -> void:
	to.global_position = Config.camera_3d.unproject_position(from.global_position + o)
	to.global_rotation = -from.global_rotation.y
	
