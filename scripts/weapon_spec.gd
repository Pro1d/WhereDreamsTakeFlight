class_name WeaponSpec
extends Resource

enum Type {
	BatteryCell = 0, # explosive
	Lego,            # split
	MagnetStick,     # seeker
	Pen,             # piercing
	RubberDuck,      # bouncing
	DollFork,        # bonus proj
	Basic,           # base stat
}

@export var type : Type
@export var fire_delay_factor := 1.0
@export var damage_factor := 1.0
@export var speed_factor := 1.0
@export var lifetime_factor := 1.0
@export var bonus_projectile := 0
@export var explosive := false
@export var piercing := false
@export var bouncing := false
@export var splitting := false
@export var seeking := false
@export var proj_shape := Projectile.Shape.Circle
@export var proj_color := Color.WHITE
@export var mesh : ArrayMesh
@export var bonus_bouncing := 0

func merge_with(other: WeaponSpec) -> void:
	if other.type == Type.Basic:
		return
	fire_delay_factor *= other.fire_delay_factor ** .5
	damage_factor *= other.damage_factor ** .5
	speed_factor *= other.speed_factor ** .5
	lifetime_factor *= other.lifetime_factor ** .5
	bonus_projectile += maxi(0, other.bonus_projectile - 1)
	explosive = explosive or other.explosive
	piercing = piercing or other.piercing
	bouncing = bouncing or other.bouncing
	splitting = splitting or other.splitting
	seeking = seeking or other.seeking
	bonus_bouncing += other.bonus_bouncing

func display_name() -> String:
	match type:
		Type.BatteryCell: return "battery"
		Type.Lego: return "lego"
		Type.MagnetStick: return "magnets"
		Type.Pen: return "pen"
		Type.RubberDuck: return "duck"
		Type.DollFork: return "fork"
		Type.Basic: return "canon"
		_: return "???"

func display_desc() -> String:
	match type:
		Type.BatteryCell: return "Explosive!"
		Type.Lego: return "Split on hit."
		Type.MagnetStick: return "Seek target."
		Type.Pen: return "Pierce target."
		Type.RubberDuck: return "Bouncing!"
		Type.DollFork: return "More shots."
		Type.Basic: return "No effect."
		_: return "???"
