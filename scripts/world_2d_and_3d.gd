class_name GameWorld3D
extends Node3D

@onready var _menu := %Menu as Menu
@onready var _modulate_2d := %CanvasModulate2D as CanvasModulate
@onready var arms := %Arms as Arms
@onready var _game_2d := %"2D" as Game2D

const modulate_2_alpha := 0.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.root_3d = $"3D"
	_modulate_2d.color.a = modulate_2_alpha
	
	_game_2d.start_game()
	#await get_tree().create_timer(5.0).timeout
	#await pause_2d()
	#await get_tree().create_timer(2.0).timeout
	#resume_2d()

func pause_2d() -> void:
	var tween := create_tween()
	const duration := 1.0
	tween.tween_property(_modulate_2d, "color:a", 0.0, duration).from(modulate_2_alpha) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", 1.0, duration).from(.5)
	tween.play()
	
	get_tree().paused = true
	await tween.finished
	
func resume_2d() -> void:
	var tween := create_tween()
	const duration := 1.0
	tween.tween_property(_modulate_2d, "color:a", modulate_2_alpha, duration).from(0.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", .5, duration).from(1.0)
	tween.play()
	
	_menu.hide()
	await tween.finished
	get_tree().paused = false

func player_pick_weapon(w1: Weapon, w2: Weapon, free_slots: Array[bool], repair_allowed: bool) -> Weapon:
	await pause_2d()
	
	# TODO anim: put plane closer
	
	var wp_overlay := %WeaponOverlay as WeaponOverlay
	wp_overlay.show()
	
	# Pick weapon / repair
	wp_overlay.show_weapon_options(
		w1.weapon_spec.display_name(),
		w2.weapon_spec.display_name(),
		w1.weapon_spec.display_desc(),
		w2.weapon_spec.display_desc(),
		repair_allowed
	)
	await wp_overlay.weapon_picked
	var ws : Array[Weapon] = [w1, w2]
	var selected_weapon : Weapon = null
	if wp_overlay.last_weapon_picked == WeaponOverlay.REPAIR:
		pass
	else:
		# TODO anim: pick weapon
		selected_weapon = ws[wp_overlay.last_weapon_picked]
	
	# Select slot
	if selected_weapon != null:
		wp_overlay.show_slots(free_slots)
		await wp_overlay.slot_picked
		# TODO anim: put weapon
		selected_weapon.index = wp_overlay.last_slot_selected
	
	wp_overlay.hide()
	# TODO anim: restore plane pos
	await resume_2d()
	
	return selected_weapon
