extends CharacterBody2D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	set_movement_target((Vector2(3,2) + Vector2(.5,.5)) * 16 * 4)

func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		print("not finished")
		return
	
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	($"../Node2D" as Node2D).global_position = next_path_position
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	($Line2D as Line2D).points[1] = new_velocity
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
