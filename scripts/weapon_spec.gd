class_name WeaponSpec
extends Resource

enum Type {
	BatteryCell = 0, # explosive
	Lego,            # split
	MagnetStick,     # seeker
	Pen,             # piercing
	RubberDuck,      # bouncing
	DollFork,        # bonus proj
}

@export var type : Type
@export var fire_delay_factor := 1.0
@export var damage_factor := 1.0
@export var speed_factor := 1.0
@export var bonus_projectile := 0
@export var explosive := false
@export var piercing := false
@export var bouncing := false
@export var splitting := false
@export var seeking := false
@export var proj_shape := Projectile.Shape.Circle
@export var proj_color := Color.WHITE
@export var mesh : ArrayMesh

func merge_with(other: WeaponSpec) -> void:
	fire_delay_factor *= other.fire_delay_factor ** .5
	damage_factor *= other.damage_factor ** .5
	speed_factor *= other.speed_factor ** .5
	bonus_projectile += maxi(0, other.bonus_projectile - 1)
	explosive = explosive or other.explosive
	piercing = piercing or other.piercing
	bouncing = bouncing or other.bouncing
	splitting = splitting or other.splitting
	seeking = seeking or other.seeking
