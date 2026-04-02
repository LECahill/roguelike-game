extends Node2D

@onready var movement_component: MovementComponent = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var attack_component: AttackComponent = %AttackComponent


const TILE_SIZE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TurnManager.player = self
	health_component.died.connect(on_death)
	movement_component.grid_position = DungeonManager.get_spawn_point()
	position = Vector2(movement_component.grid_position * TILE_SIZE)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func try_move(direction: Vector2i) -> bool:
	return movement_component.try_move(direction)
	
func on_death():
	TurnManager.enemies.erase(self)
	queue_free()
