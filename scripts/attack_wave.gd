class_name AttackWave
extends Node2D

signal cleared()

const expected_back_path_length := 700.0
@export var from_back_speed := 200.0 # px/s

@onready var _from_back := %FromBackPathFollow2D as PathFollow2D

var _enemies : Array[Enemy]
var total_max_hitpoints := 0.0
var killed_enemies := 0
#var _path_follows : Array[PathFollow2D]

func _ready() -> void:
	_from_back.progress = 0.0
	_find_enemies(self, false)
	total_max_hitpoints = compute_total_hitpoints()
	#_find_path_follows(self, false)

func compute_total_hitpoints() -> float:
	var sum := 0.0
	for e in _enemies:
		sum += e.hit_points
	return sum

func _physics_process(delta: float) -> void:
	_from_back.progress += delta * from_back_speed
	for e: Enemy in _enemies.duplicate():
		var pf := e.get_parent() as PathFollow2D
		if pf == null:
			continue
		var distance := delta * e.move_speed
		var pfo := pf as PathFollowWithOffet
		if pfo != null:
			pfo.start_distance_offset -= distance
			distance = maxf(-pfo.start_distance_offset, 0)
			pfo.start_distance_offset = maxf(pfo.start_distance_offset, 0)
		pf.progress += distance
		if pf.progress_ratio > 1.0-1e-4 and not pf.loop and pf != _from_back:
			e.destroy(false)

func _on_enemy_destroyed(killed: bool, e: Enemy) -> void:
	if killed:
		killed_enemies += 1
	_remove_enemy(e)

func _remove_enemy(e: Enemy) -> void:
	if _enemies.has(e):
		_enemies.erase(e)
		if _enemies.is_empty():
			cleared.emit()

func _find_enemies(n: Node, from_back: bool) -> void:
	if n is Enemy:
		var e := (n as Enemy)
		_enemies.append(e)
		e.destroyed.connect(_on_enemy_destroyed.bind(e))
		e.first_shoot_delay += expected_back_path_length / from_back_speed
	else:
		if n == _from_back:
			from_back = true
		for c in n.get_children():
			_find_enemies(c, from_back)

#func _find_path_follows(n: Node, from_back: bool) -> void:
	#if n is PathFollow2D:
		#if n != _from_back:
			#_path_follows.append(n)
	#else:
		#for c in n.get_children():
			#_find_path_follows(c, from_back)
