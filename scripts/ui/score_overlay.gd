class_name ScoreOverlay
extends Control

signal continue_clicked

func _ready() -> void:
	(%MenuButton as Button).pressed.connect(continue_clicked.emit)

func set_victory(v: bool) -> void:
	(%ResultLabel as Label).text = "Victory!" if v else "Defeat!"
	(%ResultLabel as Label).label_settings.font_color = Color(0.478, 1, 0.635) if v else Color(0.82, 0.392, 0.392)

func commit_xp_gain(enemy: int, boss: int) -> void:
	var total := enemy + boss
	_display_xp(enemy, boss, total)
	var t := create_tween()
	t.tween_method(_display_total_xp, 0, total, 2.0) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.play()
	(%MenuButton as Button).disabled = true
	await WhalepassSingleton.progress_xp(total)
	(%MenuButton as Button).disabled = false

func _display_xp(e: int, b: int, t: int) -> void:
	(%SummaryLabel as Label).text = "Waves completed: %d exp\nBoss killed: %d exp" % [e, b]
	_display_total_xp(t)
func _display_total_xp(t: int) -> void:
	(%TotalLabel as Label).text = "Total: %d exp" % [t]
