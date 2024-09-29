class_name PlayerPlane
extends Node3D

enum Type {
	Wood = 0,
	FireRed,
	BlackAndWhite,
	EmeraldGreen,
	AboveSky
}
const base_speed := 0.4
var speed := base_speed

@export var type : Type :
	set(t):
		if t != type:
			type = t
			_update_plane_type()

@export var meshes_by_type : Array[ArrayMesh] = []

@onready var _default_y_pos := global_position.y
@onready var weapon_slots : Array[Node3D]
@onready var plane_mesh := %Plane as MeshInstance3D

var equipped_weapons : Array[Weapon] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var i := 0
	for wp: Node3D in $"3D/WeaponPositions".get_children():
		weapon_slots.append(wp)
		if wp.get_child_count() > 0:
			equipped_weapons.append(wp.get_child(0))
			equipped_weapons.back().index = i
		else:
			equipped_weapons.append(null)
		i += 1
	_update_plane_type()

func _physics_process(delta: float) -> void:
	var command := Vector2(
		Input.get_axis("player_left", "player_right"),
		-Input.get_axis("player_up", "player_down"),
	)
	var pos_2d := Vector2(global_position.x, -global_position.z)
	pos_2d += command * speed * delta
	pos_2d = pos_2d.clamp(Config.PLAYER_AREA.position, Config.PLAYER_AREA.position + Config.PLAYER_AREA.size)
	global_position = Vector3(pos_2d.x, _default_y_pos, -pos_2d.y)
	global_rotation.x = signf(pos_2d.y) * absf(pos_2d.y / Config.PLAYER_AREA.size.y*2) ** 1.3 * (PI / 6)

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
	
func _update_plane_type() -> void:
	speed = base_speed * (1.15 if type == Type.AboveSky else 1.0)
	if plane_mesh == null: return
	plane_mesh.mesh = meshes_by_type[type]
