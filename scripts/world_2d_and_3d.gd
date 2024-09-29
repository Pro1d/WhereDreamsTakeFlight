extends Node3D

@onready var _menu := %Menu as Menu
@onready var _modulate_2d := %CanvasModulate2D as CanvasModulate
@onready var arm_mesh := $"3D/arms_low_poly2/metarig/Skeleton3D/Arm" as MeshInstance3D
@export var wave_resources : Array[PackedScene] = []
@export var current_wave_index := 0
var current_wave : AttackWave

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.player_node = %PlayerPlane
	Config.root_2d = $"2D"
	Config.root_3d = $"3D"
	_menu.hide()
	_modulate_2d.color.a = 0.9
	load_next_wave()
	assert(arm_mesh != null)
	
	#await get_tree().create_timer(5.0).timeout
	#await pause_2d()
	#await get_tree().create_timer(2.0).timeout
	#resume_2d()

func load_next_wave() -> void:
	current_wave_index += 1
	if current_wave != null:
		current_wave.queue_free()
	current_wave = wave_resources[current_wave_index % wave_resources.size()].instantiate() as AttackWave
	Config.root_2d.add_child(current_wave)
	current_wave.cleared.connect(load_next_wave)

func pause_2d() -> void:
	var tween := create_tween()
	var mat := arm_mesh.get_surface_override_material(0) as StandardMaterial3D
	tween.tween_property(_modulate_2d, "color:a", 0.0, 3.0).from(1.0)
	tween.parallel().tween_property(mat, "albedo_color:a", 1.0, 3.0).from(.5)
	tween.play()
	
	get_tree().paused = true
	await tween.finished
	_menu.show()
	
func resume_2d() -> void:
	var tween := create_tween()
	var mat := arm_mesh.get_surface_override_material(0) as StandardMaterial3D
	tween.tween_property(_modulate_2d, "color:a", 1.0, 3.0).from(0.0)
	tween.parallel().tween_property(mat, "albedo_color:a", .5, 3.0).from(1.0)
	tween.play()
	
	_menu.hide()
	await tween.finished
	get_tree().paused = false
	
