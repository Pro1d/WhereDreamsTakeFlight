class_name Menu
extends Control

signal play_clicked

var _link := "https://www.discover.games/"
var plane_index := 0

func _ready() -> void:
	_display_level_progression()
	_display_plane()
	
	(%VisitButton as Button).pressed.connect(_on_link_pressed)
	(%PrevPlaneButton as Button).pressed.connect(_on_change_plane_pressed.bind(-1))
	(%NextPlaneButton as Button).pressed.connect(_on_change_plane_pressed.bind(+1))
	(%PlayButton as Button).pressed.connect(play_clicked.emit)
	WhalepassSingleton.progress_updated.connect(_on_progress_updated)
	WhalepassSingleton.inventory_updated.connect(_on_inventory_updated)
	WhalepassSingleton.link_received.connect(_on_link_received)
	
	visibility_changed.connect(func() -> void:
		if visible: WhalepassSingleton.trigger_update()
	)
	WhalepassSingleton.trigger_update()

func _on_progress_updated() -> void:
	_display_level_progression()

func _on_link_received() -> void:
	_link = WhalepassSingleton.get_redirect_link()

func _on_inventory_updated() -> void:
	_display_plane()

func _display_level_progression() -> void:
	var e := Config.get_level_from_xp()
	(%PlayerLevelLabel as Label).text = "Level %d" % [e.level] + (" (max)" if e.level == Config.Exp.max_level else "")
	(%XpLabel as Label).text = "Next Level: %d/%d Exp." % [e.xp, e.xp_next_level]
	(%XpProgressBar as ProgressBar).value = e.xp
	(%XpProgressBar as ProgressBar).max_value = e.xp_next_level

func _on_link_pressed() -> void:
	OS.shell_open(_link)

func _on_change_plane_pressed(i: int) -> void:
	var planes_count := Config.available_planes.size()
	plane_index = (plane_index + i + planes_count) % planes_count
	_display_plane()

func _display_plane() -> void:
	var type := plane_index as PlayerPlane.Type
	(%PlaneLabel as Label).text = PlayerPlane.display_description(type)
	Config.player_node.type = type
	(%PlayButton as Button).disabled = not Config.available_planes[plane_index]
