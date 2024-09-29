class_name Weapon
extends Node3D


const ProjectileResource := preload("res://scenes/projectile.tscn")

@export var index := -1  # index in player plane, for caching
@export var weapon_spec : WeaponSpec
@export var player_plane : PlayerPlane
@export var firing := true :
	set(f):
		cooldown = 0.0
		firing = f

@onready var proj_spawn_position := $"2D/ProjectileSpawn" as Node2D
		
const base_fire_delay := 0.55

var cooldown := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_mesh()

func _physics_process(delta: float) -> void:
	if firing:
		cooldown -= delta
		if cooldown <= 0.0:
			cooldown += base_fire_delay * weapon_spec.fire_delay_factor
			_fire()

func _fire() -> void:
	var known_types := {weapon_spec.type: null}
	var ws := weapon_spec.duplicate() as WeaponSpec
	for nw: Weapon in player_plane.get_neighboring_weapon(self):
		if not known_types.has(nw.weapon_spec.type):
			ws.merge_with(nw.weapon_spec)
			known_types[nw.weapon_spec.type] = null
	
	player_plane.merge_plane_spec(ws, index)
	
	var count := ws.bonus_projectile + 1
	var max_angle := deg_to_rad(10)
	var step_angle := max_angle * 2 / (count - 1)
	var angle := -max_angle if count > 1 else 0.0
	var origin := proj_spawn_position.global_position
	var base_dir := proj_spawn_position.global_transform.x
	
	for i in range(count):
		var dir := base_dir.rotated(angle)
		var projectile := ProjectileResource.instantiate() as Projectile
		projectile.global_position = origin
		projectile.color = ws.proj_color
		projectile.shape_type = ws.proj_shape
		projectile.by_player = true
		projectile.current_velocity = projectile.current_velocity.length() * dir * ws.speed_factor
		projectile.bounce_left = 3 if ws.bouncing else 0
		projectile.piercing = ws.piercing
		projectile.seeking = ws.seeking
		projectile.explosive = ws.explosive
		projectile.split_on_hit = ws.splitting
		projectile.damage *= ws.damage_factor
		projectile.lifetime *= ws.lifetime_factor
		get_tree().root.add_child(projectile)
		
		angle += step_angle
	
	# TODO SoundFx

func _update_mesh() -> void:
	(%Mesh as MeshInstance3D).mesh = weapon_spec.mesh
