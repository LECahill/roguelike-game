class_name Enemy extends Node2D
@onready var movement_component: MovementComponent = $MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var attack_component: AttackComponent = %AttackComponent

const TILE_SIZE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TurnManager.enemies.append(self)
	health_component.died.connect(on_death)
	movement_component.grid_position = DungeonManager.get_spawn_point()
	position = Vector2(movement_component.grid_position * TILE_SIZE)
	
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
	
func is_adjacent_to_player() -> bool:
	var difference : Vector2i
	difference = TurnManager.player.movement_component.grid_position - movement_component.grid_position
	if abs(difference.x) == 1 and abs(difference.y) == 0:
		return true
	elif abs(difference.x) == 0 and abs(difference.y) == 1:
		return true
	else:
		return false
	
func on_death():
	TurnManager.enemies.erase(self)
	queue_free()
