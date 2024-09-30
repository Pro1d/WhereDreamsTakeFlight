class_name PlayerPlane
extends CharacterBody2D

signal destroyed()

enum Type {
	Wood = 0,
	FireRed,
	BlackAndWhite,
	EmeraldGreen,
	AboveSky
}
const base_speed := 500.0
var speed := base_speed
var max_hitpoint := 5
var hitpoint := max_hitpoint

@export var type : Type :
	set(t):
		type = t
		_update_plane_type()

var _shielded := false :
	set(s):
		_shielded = s
		_update_shield()
var shield_tween : Tween

@onready var _remote_transform := %RemoteTransform2DTo3D as RemoteTransform2DTo3D
@onready var _root_3d := %"3D" as Node3D
@onready var _default_y_pos := _root_3d.global_position.y
@onready var weapon_slots_3d : Array[Node3D]
@onready var plane_mesh := %Plane as MeshInstance3D
@onready var _hit_box_area := %HitBoxArea as Area2D
@onready var shield_shape := $ShieldShape as CollisionShape2D

var equipped_weapons : Array[Weapon] = []

func _enter_tree() -> void:
	Config.player_node = self

func _ready() -> void:
	var i := 0
	for wp: Node3D in $"3D/WeaponPositions".get_children():
		weapon_slots_3d.append(wp)
		equipped_weapons.append(null)
		if wp.get_child_count() > 0:
			var w := wp.get_child(0) as Weapon
			wp.remove_child(w)
			add_child(w)
			w.index = i
			add_weapon(w)
		i += 1
	
	_update_shield()
	_update_plane_type()
	(%ShieldAnimationPlayer as AnimationPlayer).play("shielding")
	
	#remove_child(_root_3d)
	##Config.root_3d.add_child(_root_3d)
	#get_tree().root.add_child(_root_3d)
	
	_hit_box_area.body_entered.connect(_on_hit_box_entered)
	# Custom remote transform
	_remote_transform.position_updated.connect(func(t2d: Transform2D) -> void:
		_root_3d.global_position.y = _default_y_pos
		var half_h := 768.0 / 2
		_root_3d.global_rotation.x = signf(t2d.origin.y - half_h) * absf((t2d.origin.y - half_h) / half_h) ** 1.5 * (-PI / 6)
	)

func reset() -> void:
	hitpoint = max_hitpoint
	for i in range(equipped_weapons.size()):
		if equipped_weapons[i] != null:
			remove_weapon(i)
	global_position = Vector2(300.0, 768.0 / 2)

func set_firing(f: bool) -> void:
	for w in equipped_weapons:
		if w != null:
			w.firing = f

func _physics_process(delta: float) -> void:
	var command := Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down"),
	)
	move_and_collide(command * speed * delta)

func add_weapon(weapon: Weapon) -> void:
	var index := weapon.index
	if equipped_weapons[index] != null:
		remove_weapon(index)
	equipped_weapons[index] = weapon
	weapon_slots_3d[index].add_child(weapon.take_root_3d())
	weapon.firing = true
	weapon.player_plane = self

func remove_weapon(index: int) -> void:
	var w := equipped_weapons[index]
	if w == null:
		return
	equipped_weapons[index] = null
	weapon_slots_3d[index].remove_child(w._root_3d)
	w.return_root_3d()
	w.firing = false
	w.player_plane = null
	w.queue_free()

func get_neighboring_weapon(weapon: Weapon) -> Array[Weapon]:
	var nw : Array[Weapon] = []
	
	var weapon_index := weapon.index
	for i in equipped_weapons.size():
		if absi(i - weapon_index) == 1:
			if equipped_weapons[i] != null:
				nw.append(equipped_weapons[i])

	return nw

func merge_plane_spec(ws: WeaponSpec, weapon_index: int) -> void:
	match type:
		Type.Wood:
			pass
		Type.FireRed:
			var c := equipped_weapons.size() - equipped_weapons.count(null)
			if c == 1:
				ws.damage_factor *= 2.0
			elif c == 2:
				ws.damage_factor *= 1.0
		Type.BlackAndWhite:
			ws.damage_factor *= 1.1
		Type.EmeraldGreen:
			if weapon_index == 1:
				ws.fire_delay_factor *= 1 / 1.25
		Type.AboveSky:
			ws.speed_factor *= 1.15
			ws.damage_factor *= 1.05
			ws.fire_delay_factor *= 1 / 1.05
			# 15% flying speed

static func display_description(t: Type) -> String:
	match t:
		Type.Wood:
			return "\"My first ever plane!\"\n-"
		Type.FireRed:
			return "\"Uncle's gift for my birthday.\"\n2x damage with only one weapon equiped."
		Type.BlackAndWhite:
			return "\"It's a strong plane.\"\n+10% damage"
		Type.EmeraldGreen:
			return "\"My favorite color.\"\n+25% fire rate to middle weapon."
		Type.AboveSky:
			return "\"Sky isn't the limit!\"\n+5% damage and fire rate.\n+15% projectile and plane speed."
		_:
			return "???\n-"
func _update_plane_type() -> void:
	speed = base_speed * (1.15 if type == Type.AboveSky else 1.0)
	if plane_mesh == null: return
	plane_mesh.mesh = Config.plane_model_resources[type]
	const black_mat := preload("res://resources/materials/black_unshaded.tres") 
	var mat := (null if Config.available_planes[type] else black_mat) as Material
	for i in range(plane_mesh.get_surface_override_material_count()):
		plane_mesh.set_surface_override_material(0, mat)

func _update_shield() -> void:
	shield_shape.modulate.a = 1.0
	shield_shape.visible = _shielded
	shield_shape.disabled = not _shielded

func _on_hit_box_entered(body: PhysicsBody2D) -> void:
	#var proj := body as Projectile
	#if proj != null and not proj.by_player:
		#proj.destroy_projectile(true)
		#take_damage()
	var enemy := Enemy.find_parent_enemy(body)
	if enemy != null:
		take_damage()

func take_damage() -> void:
	if _shielded:
		return
	
	hitpoint -= 1
	if hitpoint == 0:
		destroyed.emit()
	else:
		trigger_shield()
	# TODO fx, shield

func trigger_shield() -> void:
	const duration := 2.5
	const fade_duration := .2
	
	if shield_tween != null:
		shield_tween.kill()
		shield_tween = null
	
	_shielded = true
	shield_tween = create_tween()
	shield_tween.tween_interval(duration - fade_duration)
	shield_tween.tween_property(shield_shape, "modulate:a", 0.0, fade_duration).from(1.0)
	shield_tween.tween_callback(func() -> void: _shielded = false)

func disable_shield() -> void:
	if shield_tween != null:
		shield_tween.kill()
		shield_tween = null
	_shielded = false

func get_2d_position() -> Vector2:
	return global_position

func get_3d_node() -> Node3D:
	return %"3D" as Node3D
