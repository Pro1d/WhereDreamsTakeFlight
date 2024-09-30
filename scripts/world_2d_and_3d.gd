class_name GameWorld3D
extends Node3D

@onready var _menu := %Menu as Menu
@onready var _modulate_2d := %CanvasModulate2D as CanvasModulate
@onready var arms := %Arms as Arms
@onready var _game_2d := %"2D" as Game2D

var right_hand_tween : Tween
var right_hand_grabbed_obj : Node3D

const modulate_2_alpha := 0.9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.root_3d = $"3D"
	_modulate_2d.color.a = modulate_2_alpha
	grab_with_right_hand(null)
	_game_2d.start_game()
	#await get_tree().create_timer(2.0).timeout
	#await pause_2d()
	#await get_tree().create_timer(2.0).timeout
	#resume_2d()

func pause_2d() -> void:
	var tween := create_tween()
	const duration := 0.25
	tween.tween_property(_modulate_2d, "color:a", 0.5, duration).from(modulate_2_alpha) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", 1.0, duration).from(.5)
	tween.play()
	
	get_tree().paused = true
	await tween.finished
	
func resume_2d() -> void:
	var tween := create_tween()
	const duration := 0.5
	tween.tween_property(_modulate_2d, "color:a", modulate_2_alpha, duration).from(0.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(arms.mat, "albedo_color:a", .5, duration).from(1.0)
	tween.play()
	
	_menu.hide()
	await tween.finished
	get_tree().paused = false

func player_pick_weapon(w1: Weapon, w2: Weapon, free_slots: Array[bool], repair_allowed: bool) -> Weapon:
	await pause_2d()
	var tween : Tween
	
	# Animate plane close up view
	var plane_3d := Config.player_node.get_3d_node()
	var play_plane_transform := plane_3d.transform
	var plane_close_transform := (%PlaneCloseUpMarker3D as Node3D).global_transform
	var duration := 0.8 + plane_close_transform.origin.distance_to(play_plane_transform.origin) / (.4)
	tween = create_tween()
	tween.tween_property(plane_3d, "transform", plane_close_transform, duration) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	await tween.finished
	
	# Open UI
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
		selected_weapon.index = wp_overlay.last_slot_selected
		
		# Animate grab and place weapon
		await grab_with_right_hand(selected_weapon._root_3d, 0.4)
		
		var slot_transform := Config.player_node.weapon_slots_3d[selected_weapon.index].global_transform
		tween = create_tween()
		tween.tween_property(selected_weapon._root_3d, "global_transform", slot_transform, 0.5) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_interval(0.1)
		await tween.finished
		
		Config.player_node.add_weapon(selected_weapon)
		
		await grab_with_right_hand(null, 0.4)
	
	# Close UI
	wp_overlay.hide()
	
	# Animate plane returning to play area
	tween = create_tween()
	tween.tween_property(plane_3d, "transform", play_plane_transform, duration) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	await tween.finished
	
	await resume_2d()
	
	return selected_weapon

func _physics_process(_delta: float) -> void:
	if right_hand_grabbed_obj != null and (right_hand_tween == null or not right_hand_tween.is_running()):
		(%RightHandMovableMarker3D as Node3D).global_transform = right_hand_grabbed_obj.global_transform

func grab_with_right_hand(obj: Node3D, speed: float = 0.0) -> void:
	var ik := %SkeletonIK3DRight as SkeletonIK3D
	var interp_target := (%RightHandMovableMarker3D as Node3D)
	if not ik.is_running():
		ik.start()
	right_hand_grabbed_obj = obj if obj != null else (%RightHandRestMarker3D as Node3D)
	
	if right_hand_tween != null:
		right_hand_tween.kill()
		right_hand_tween = null
	
	if speed > 1e-4:
		#var skeleton := ik.get_parent() as Skeleton3D
		var start_pos := interp_target.global_position # skeleton.get_bone_global_pose(skeleton.find_bone(ik.tip_bone)).origin
		var end_pos := right_hand_grabbed_obj.global_position
		var duration := clampf(start_pos.distance_to(end_pos) / speed, 0.2, 5.0)
		
		right_hand_tween = create_tween()
		right_hand_tween.tween_property(interp_target, "global_transform", right_hand_grabbed_obj.global_transform, duration) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		right_hand_tween.play()
		
		await right_hand_tween.finished
	else:
		interp_target.global_transform = right_hand_grabbed_obj.global_transform
