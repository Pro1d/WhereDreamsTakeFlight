class_name Game2D
extends Node2D

enum State {
	IDLE,
	PLAYING,
	ENDING
}

const waves_count := 3

@export var wave_resources : Array[PackedScene] = []
@export var boss_resources : Array[PackedScene] = []
@export var current_wave_index := 0
var current_wave : AttackWave
var _state := State.IDLE
var completed_waves := 0

@onready var player_plane := %PlayerPlane as PlayerPlane


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	Config.root_2d = self

func _ready() -> void:
	player_plane.destroyed.connect(_on_player_destroyed)
	player_plane.set_firing(false)

func reset() -> void:
	_clear_nodes(self)

func start_game() -> void:
	reset()
	player_plane.reset()
	player_plane.set_firing(true)
	completed_waves = 0
	load_next_wave()
	_state = State.PLAYING

func _on_wave_cleared() -> void:
	completed_waves += 1
	if completed_waves < waves_count:
		load_next_wave()
	else:
		finish_game(true)

func  load_next_wave() -> void:
	completed_waves += 1
	if completed_waves < waves_count - 1:
		load_wave(randi_range(0, wave_resources.size() - 1), false)
	else:
		load_wave(randi_range(0, boss_resources.size() - 1), true)

func load_wave(index: int, boss: bool) -> void:
	if current_wave != null:
		current_wave.queue_free()
	if boss:
		current_wave = boss_resources[index].instantiate() as AttackWave
	else:
		current_wave = wave_resources[index].instantiate() as AttackWave
	Config.root_2d.add_child(current_wave)
	current_wave.cleared.connect(_on_wave_cleared)

func finish_game(_victory: bool) -> void:
	_state = State.ENDING
	current_wave.queue_free()
	current_wave = null
	# TODO await end animation
	_state = State.IDLE
	player_plane.set_firing(false)

func _clear_nodes(n: Node) -> void:
	for c in n.get_children():
		if c.is_in_group("unique_to_game"):
			c.queue_free()
		else:
			_clear_nodes(c)

func _on_player_destroyed() -> void:
	match _state:
		State.PLAYING:
			finish_game(false)
