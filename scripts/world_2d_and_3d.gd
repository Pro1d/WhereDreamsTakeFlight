class_name GameWorld3D
extends Node3D

@onready var _menu := %Menu as Menu
@onready var _modulate_2d := %CanvasModulate2D as CanvasModulate
@onready var arms := %Arms as Arms
@onready var _game_2d := %"2D" as Game2D

var right_hand_tween : Tween
var right_hand_grabbed_obj : Node3D

const modulate_2_alpha := 0.9
const camera_rotation_menu := PI / 3
const arms_position_menu := Vector3(0, 0, 0.700)
const anim_duration_menu := 1.0
var plane_pos_before_menu : Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.root_3d = $"3D"
	_modulate_2d.color.a = modulate_2_alpha
	grab_with_right_hand(null)
	_menu.play_clicked.connect(_on_play_clicked)
	_game_2d.game_finished.connect(_on_game_finished)
	SoundFxManagerSingleton.connect_all_buttons($HUD)
	pause_2d(true)
	show_menu()
	start_audio()

func start_audio() -> void:
	VoiceManagerSingleton.play(VoiceManager.Type.Intro)
	await get_tree().create_timer(7.0).timeout
	MusicManager.start_music()

func _on_play_clicked() -> void:
	await resume_2d()
	await hide_menu()
	_game_2d.start_game()

func _on_game_finished() -> void:
	await pause_2d()
	show_menu()
	
func show_menu() -> void:
	var plane_3d := Config.player_node.get_3d_node()
	plane_pos_before_menu = plane_3d.global_transform
	var target_plane_pos := (%PlaneMenuMarker3D as Node3D).global_transform
	var tween := create_tween()
	tween.tween_property(plane_3d, "global_transform", target_plane_pos, anim_duration_menu * .9) \
		.from_current().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(arms, "global_position", arms_position_menu, anim_duration_menu * .9) \
		.from_current().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(%CameraAxis as Node3D, "rotation:x", camera_rotation_menu, anim_duration_menu) \
		.from_current().set_delay(anim_duration_menu * .1) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	grab_with_right_hand(%RightHandMenuMarker3D as Node3D, 0.4)
	await tween.finished
	
	_menu.show()

func hide_menu() -> void:
	var plane_3d := Config.player_node.get_3d_node()
	var tween := create_tween()
	tween.tween_property(plane_3d, "global_transform", plane_pos_before_menu, anim_duration_menu * .9) \
		.from_current().set_delay(anim_duration_menu * .1) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(arms, "global_position", Vector3.ZERO, anim_duration_menu * .9) \
		.from_current().set_delay(anim_duration_menu * .1) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(%CameraAxis as Node3D, "rotation:x", 0.0, anim_duration_menu) \
		.from_current() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	grab_with_right_hand(%RightHandRestMarker3D as Node3D, 0.4)
	await tween.finished
	
	_menu.hide()

func pause_2d(instant: bool = false) -> void:
	get_tree().paused = true
	if instant:
		_modulate_2d.color.a = 0.0
	else:
		var tween := create_tween()
		const duration := 0.25
		tween.tween_property(_modulate_2d, "color:a", 0.0, duration).from(modulate_2_alpha) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.play()
		await tween.finished
	
func resume_2d() -> void:
	var tween := create_tween()
	const duration := 0.5
	tween.tween_property(_modulate_2d, "color:a", modulate_2_alpha, duration).from(0.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	
	_menu.hide()
	await tween.finished
	get_tree().paused = false

func player_pick_weapon(w1: Weapon, w2: Weapon, free_slots: Array[bool], repair_allowed: bool) -> Weapon:
	w1._root_3d.hide()
	w2._root_3d.hide()
	
	await pause_2d()
	var tween : Tween
	
	# Animate plane close up view
	var plane_3d := Config.player_node.get_3d_node()
	var play_plane_transform := plane_3d.transform
	var plane_close_transform := (%PlaneCloseUpMarker3D as Node3D).global_transform
	var duration := clampf(plane_close_transform.origin.distance_to(play_plane_transform.origin) / 0.4, 0.2, 5.0)
	tween = create_tween()
	tween.tween_property(plane_3d, "transform", plane_close_transform, duration) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	await tween.finished
	
	# Open UI
	var wp_overlay := %WeaponOverlay as WeaponOverlay
	wp_overlay.show()
	w1._root_3d.show()
	w2._root_3d.show()
	
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
		selected_weapon = ws[wp_overlay.last_weapon_picked]
	
	if w1 != selected_weapon:
		w1.return_root_3d()
		w1.queue_free()
	if w2 != selected_weapon:
		w2.return_root_3d()
		w2.queue_free()
	
	# Select slot
	if selected_weapon != null:
		wp_overlay.show_slots(free_slots)
		await wp_overlay.slot_picked
		selected_weapon.index = wp_overlay.last_slot_selected
		
		# Animate grab and place weapon
		VoiceManagerSingleton.play(VoiceManager.Type.EquipWeapon)
		await grab_with_right_hand(selected_weapon._root_3d, 0.4)
		Config.player_node.remove_weapon(selected_weapon.index)
		
		var slot_transform := Config.player_node.weapon_slots_3d[selected_weapon.index].global_transform
		tween = create_tween()
		tween.tween_property(selected_weapon._root_3d, "global_transform", slot_transform, 0.5) \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_interval(0.1)
		await tween.finished
		
		Config.player_node.add_weapon(selected_weapon)
		
		await grab_with_right_hand(null, 0.4)
	else:
		VoiceManagerSingleton.play(VoiceManager.Type.Repair)
		Config.player_node.hitpoint = mini(Config.player_node.hitpoint + Config.REPAIR_HEALTH, Config.player_node.max_hitpoint)
	
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
	#var ik := arms.skeleton_ik_left
	var interp_target := (%RightHandMovableMarker3D as Node3D)
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
