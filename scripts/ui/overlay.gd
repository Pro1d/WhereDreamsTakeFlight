class_name Overlay
extends Control

@onready var player_pb := %PlayerProgressBar as ProgressBar
@onready var enemy_pb := %EnemyProgressBar as ProgressBar

var func_player_hp : Callable
var func_player_max_hp : Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if not func_player_hp.is_null() and not func_player_max_hp.is_null():
		set_player_hp(func_player_hp.call() as int, func_player_max_hp.call() as int)

func show_enemy_life(hp: int, max_hp: int) -> void:
	enemy_pb.show()
	enemy_pb.max_value = max_hp
	enemy_pb.value = hp

func hide_enemy_life() -> void:
	enemy_pb.hide()

func set_player_hp(hp: int, max_hp: int) -> void:
	player_pb.max_value = max_hp
	player_pb.value = hp
	
