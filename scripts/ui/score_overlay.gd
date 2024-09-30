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
	(%SummaryLabel as Label).text = "Enemies killed: %d xp\nBoss killed: %d xp" % [enemy, boss]
	(%TotalLabel as Label).text = "Total: %d xp" % [total]
	(%MenuButton as Button).disabled = true
	await WhalepassSingleton.progress_xp(total)
	(%MenuButton as Button).disabled = false
