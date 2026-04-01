extends Node2D
@onready var movement_component: MovementComponent = $MovementComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TurnManager.enemies.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func calculate_direction() -> Vector2i:
	var direction : Vector2i 
	var difference : Vector2i
	# get difference
	difference = TurnManager.player.movement_component.grid_position - movement_component.grid_position
	#deterine which axis has the largest number
	if abs(difference.x) > abs(difference.y):
		direction = Vector2i(sign(difference.x),0)
	else:
		direction = Vector2i(0,sign(difference.y))
	return direction

func try_move(direction: Vector2i) -> bool:
	return movement_component.try_move(direction)
