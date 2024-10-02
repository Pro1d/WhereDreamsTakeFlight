extends Node

enum Volume { LOW=1, HIGH=2 }

#const menu_music := preload("res://assets/musics/last-stand-in-space.ogg")
const game_music := preload("res://assets/musics/kevin_macleod_-_bassa_island_game_loop.ogg") #"res://assets/musics/the_child.ogg")
const musics_interactive := preload("res://resources/audio/musics.tres") as AudioStreamInteractive

var _vol := Volume.HIGH
var _mute := false
@onready var _player := AudioStreamPlayer.new()
@onready var _music_bus := AudioServer.get_bus_index(&"Music")
@onready var _default_volume_db := AudioServer.get_bus_volume_db(_music_bus)


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_player.bus = &"Music"
	set_volume(_vol)
	add_child(_player)
	_player.stream = musics_interactive
	for i in range(2):
		musics_interactive.add_transition(
			i, 1 - i,
			AudioStreamInteractive.TRANSITION_FROM_TIME_IMMEDIATE,
			AudioStreamInteractive.TRANSITION_TO_TIME_START,
			AudioStreamInteractive.FADE_CROSS, 
			2.0, false, -1, i == 0
		)
	musics_interactive.set_clip_auto_advance(0, AudioStreamInteractive.AUTO_ADVANCE_RETURN_TO_HOLD)

func start_music() -> void:
	_player.play()

func switch_to_boss_music() -> void:
	(_player.get_stream_playback() as AudioStreamPlaybackInteractive).switch_to_clip_by_name("boss")

func switch_to_main_music() -> void:
	(_player.get_stream_playback() as AudioStreamPlaybackInteractive).switch_to_clip_by_name("main")

func toggle_mute() -> void:
	set_mute(not _mute)
	
func set_mute(m: bool) -> void:
	_mute = m
	AudioServer.set_bus_mute(_music_bus, _mute)

func is_mute() -> bool:
	return _mute

func set_volume(level: Volume) -> void:
	set_mute(false)
	_vol = level
	match level:
		Volume.HIGH:
			AudioServer.set_bus_volume_db(_music_bus, _default_volume_db)
		Volume.LOW:
			AudioServer.set_bus_volume_db(_music_bus, _default_volume_db - 9.0)
