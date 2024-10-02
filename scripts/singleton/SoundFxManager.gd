class_name SoundFxManager
extends Node

enum Type {
	EnemyShoot,
	PlayerShoot,
	PlayerHit,
	PlayerShieldHit,
	PlayerDeath,
	EnemyHit,
	EnemyDeath,
	ProjectileExplode,
	Shielding,
	ProjectileHit,
	Repair,
	Pop,
}

@onready var ui_sound := AudioStreamPlayer.new()
var _players : Array[AudioStreamPlayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	ui_sound.bus = &"UI"
	ui_sound.stream = preload("res://assets/sounds/fx/touck.ogg")
	add_child(ui_sound)
	
	var do := func(r: AudioStream, db: float = 0.0) -> AudioStreamPlayer:
		var asp := AudioStreamPlayer.new()
		var random := AudioStreamRandomizer.new()
		random.add_stream(0, r)
		random.random_pitch = 1.05
		asp.bus = &"SoundFx"
		asp.stream = random
		asp.volume_db = db
		asp.max_polyphony = 3
		add_child(asp)
		return asp
	
	_players.resize(Type.size())
	_players[Type.EnemyShoot] = do.call(preload("res://assets/sounds/fx/shoot2.ogg"))
	_players[Type.PlayerShoot] = do.call(preload("res://assets/sounds/fx/shoot1.ogg"), -8)
	_players[Type.PlayerHit] = do.call(preload("res://assets/sounds/fx/hit2.ogg"))
	_players[Type.PlayerShieldHit] = do.call(preload("res://assets/sounds/fx/ImpactOnSteelSmooth.ogg"), -6)
	_players[Type.PlayerDeath] = do.call(preload("res://assets/sounds/fx/retro_destroy_explode.ogg"))
	_players[Type.EnemyHit] = do.call(preload("res://assets/sounds/fx/hit1.ogg"), -10)
	_players[Type.EnemyDeath] = do.call(preload("res://assets/sounds/fx/MissileLaunchMini2.ogg"), -5)
	_players[Type.ProjectileExplode] = do.call(preload("res://assets/sounds/fx/MiniShot.ogg"), -12)
	_players[Type.Shielding] = do.call(preload("res://assets/sounds/fx/meld.ogg"))
	_players[Type.ProjectileHit] = do.call(preload("res://assets/sounds/fx/tuck.ogg"), -8)
	_players[Type.Repair] = do.call(preload("res://assets/sounds/fx/tliiing.ogg"))
	_players[Type.Pop] = do.call(preload("res://assets/sounds/fx/pop.ogg"))

func play(type: Type) -> void:
	_players[type].play()

func keep_until_finished(audio: Node) -> void: # AudioStreamPlayer[2D]
	audio.get_parent().remove_child(audio)
	add_child(audio)
	
	var asp := audio as AudioStreamPlayer
	if asp != null:
		asp.finished.connect(audio.queue_free)
		return
	var asp2d := audio as AudioStreamPlayer2D
	if asp2d != null:
		asp2d.finished.connect(audio.queue_free)
		return
	var asp3d := audio as AudioStreamPlayer3D
	if asp3d != null:
		asp3d.finished.connect(audio.queue_free)
		return

func connect_all_buttons(node: Node) -> void:
	if node is Button:
		connect_button(node as Button)
	if node is OptionButton:
		connect_option_button(node as OptionButton)
	for c in node.get_children():
		connect_all_buttons(c)

func connect_button(button: Button) -> void:
	button.pressed.connect(ui_sound.play)

func connect_option_button(button: OptionButton) -> void:
	button.item_selected.connect(ui_sound.play)
