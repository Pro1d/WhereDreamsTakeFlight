@tool
class_name Enemy
extends Node2D

signal destroyed(killed: bool)

const ProjectileResource := preload("res://scenes/projectile.tscn")

# Bird: contact damage only
# warplane: attack forward
# drones/copter: attack, not rot 
# spinning: bullet hell pattern
# ball: mines (slow proj), move
# teddy: curvy bullet hell patterns (curve trajectory like thrusted RC missile)
#   DROP: seeker
# Doll: circle pattern
#   Drop: fork
# train: axis aligned bullet hell patterns
#   Drop: explosive
# --> difficulty level: additional enemies, higher fire rate, additional bullets patter / aim shooter, (bullet speed)

@export var move_speed := 100.0
@export var radius := 40.0 :
	set(r):
		radius = r
		_update_radius()

@export var first_shoot_delay := 2.0
@export var auto_shoot_delay := 1.0
@export var hit_points := 50.0
@export var aim_player := false
var shot_cooldown := 0.0

@onready var _body := %Body as CharacterBody2D
@onready var _spawn_positions := %ProjectileSpawns
@onready var _visual_2d := $"2D/Body/Visual"
@onready var _visual_3d := $"3D/Visual"

func _ready() -> void:
	_update_radius()
	if Engine.is_editor_hint():
		return
	shot_cooldown = first_shoot_delay
	for c in _visual_2d.get_children():
		var l := c as Line2D
		if l != null:
			l.width_curve = Config.curve_width_resources.pick_random()
	for c in _visual_2d.get_children()+_visual_3d.get_children():
		var a := c as AnimationPlayer
		if a != null:
			a.has_animation("flying")
			a.play("flying")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if auto_shoot_delay > 1e-4:
		shot_cooldown -= delta
		if shot_cooldown <= 0:
			shot_cooldown += auto_shoot_delay
			trigger_all_shots()

func trigger_all_shots() -> void:
	SoundFxManagerSingleton.play(SoundFxManager.Type.EnemyShoot)
	for sp: Node2D in _spawn_positions.get_children():
		var dir := sp.global_transform.x
		if aim_player and  Config.player_node != null:
			dir = sp.global_position.direction_to(Config.player_node.get_2d_position())
		shoot(sp.global_position, dir)

func shoot(origin: Vector2, dir: Vector2) -> Projectile:
	var projectile := ProjectileResource.instantiate() as Projectile
	projectile.global_position = origin
	projectile.color = Color(0.618, 0.099, 0.71) if aim_player else Color(1, 0.388, 0.32)
	projectile.shape_type = Projectile.Shape.Cross
	projectile.by_player = false
	projectile.current_velocity = dir * (200.0 if aim_player else 300.0)
	projectile.damage = 1
	projectile.lifetime = 5.0
	Config.root_2d.add_child(projectile)
	return projectile

func take_damage(dmg: float) ->  void:
	SoundFxManagerSingleton.play(SoundFxManager.Type.EnemyHit)
	hit_points -= dmg
	if hit_points <= 0:
		destroy(true)

func destroy(killed: bool) -> void:
	if killed:
		# TODO fx
		pass
	destroyed.emit(killed)
	queue_free()

func _update_radius() -> void:
	if _body == null:
		return
	var circle_shape := (_body.get_child(0) as CollisionShape2D).shape as CircleShape2D
	if circle_shape != null:
		circle_shape.radius = radius

static func find_parent_enemy(body: PhysicsBody2D) -> Enemy:
	# body = "Enemy/2D/Body"
	var p := body.get_parent() # "Enemy/2D"
	if p == null:
		return null
	var pp := p.get_parent() # "Enemy"
	return pp as Enemy
