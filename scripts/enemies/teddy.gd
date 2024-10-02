extends Enemy

var attack_state := 0

@onready var side1_canons: Array[Marker2D] = [
	%SpawnA1Marker2D, %SpawnA2Marker2D
]
@onready var side2_canons: Array[Marker2D] = [
	%SpawnA3Marker2D, %SpawnA4Marker2D
]
@onready var middle4_canons: Array[Marker2D] = [
	%SpawnB1Marker2D, %SpawnB2Marker2D, %SpawnB3Marker2D
]

const seq: Array[int] = [
	1+2,  0, 4, 0, 1+2,  0, 4, 0, 1+2, 0, 4, 0, 0, 4+1, 0, 4+2, 0, 4+1, 0, 4+2, 0
]
var seq_index := 0

#func _ready() -> void:
	#super()
#
#func _physics_process(delta: float) -> void:
	#super(delta)

func trigger_all_shots() -> bool:
	if (seq[seq_index] & 1) != 0:
		for sp in side1_canons:
			var dir := sp.global_transform.x
			shoot(sp.global_position, dir)
	if (seq[seq_index] & 2) != 0:
		for sp in side2_canons:
			var dir := sp.global_transform.x
			shoot(sp.global_position, dir)
	if (seq[seq_index] & 4) != 0:
		for sp in middle4_canons:
			var dir := sp.global_transform.x
			var proj := shoot(sp.global_position, dir)
			proj.bounce_left = 1
			proj.color = Color(0.86, 0.507, 0.129)
	var fired := (seq[seq_index] != 0)
	seq_index = (seq_index + 1) % seq.size()
	return fired
