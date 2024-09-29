extends Enemy

@onready var _canons : Array[Node2D] = [%Canon1, %Canon2, %Canon3]


func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	if Config.player_node != null:
		var aim := Config.player_node.get_2d_position()
		var angle := _body.global_position.angle_to_point(aim)
		for c in _canons:
			c.global_rotation = rotate_toward(c.global_rotation, angle, delta * PI/4)
	super(delta)
