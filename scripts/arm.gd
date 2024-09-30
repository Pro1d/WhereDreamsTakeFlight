class_name Arms
extends Node3D

@onready var mat := (($arm_left/metarig_left/Skeleton3D/ArmLeft as MeshInstance3D).get_surface_override_material(0) as StandardMaterial3D)
@onready var skeleton_ik_left := %SkeletonIK3DLeft as SkeletonIK3D
@onready var skeleton_ik_right := %SkeletonIK3DRight as SkeletonIK3D
@onready var anim_left := $arm_left/AnimationPlayer as AnimationPlayer
@onready var anim_right := $arm_right/AnimationPlayer as AnimationPlayer

func _ready() -> void:
	skeleton_ik_left.start()
