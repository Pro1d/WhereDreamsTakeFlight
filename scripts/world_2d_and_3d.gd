extends Node3D

@onready var _menu := %Menu as Menu
@onready var _modulate_2d := %CanvasModulate2D as CanvasModulate
@onready var arms := %Arms as Arms
@onready var _game_2d := %"2D" as Game2D

const modulate_2_alpha := 0.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.root_3d = $"3D"
	_menu.hide()
	_modulate_2d.color.a = modulate_2_alpha
	
	_game_2d.start_game()
	#await get_tree().create_timer(5.0).timeout
	#await pause_2d()
	#await get_tree().create_timer(2.0).timeout
	#resume_2d()

func pause_2d() -> void:
	var tween := create_tween()
	const duration := 2.0
	tween.tween_property(_modulate_2d, "color:a", 0.0, duration).from(modulate_2_alpha)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", 1.0, duration).from(.5)
	tween.play()
	
	get_tree().paused = true
	await tween.finished
	_menu.show()
	
func resume_2d() -> void:
	var tween := create_tween()
	const duration := 2.0
	tween.tween_property(_modulate_2d, "color:a", modulate_2_alpha, duration).from(0.0)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", .5, duration).from(1.0)
	tween.play()
	
	_menu.hide()
	await tween.finished
	get_tree().paused = false
	
