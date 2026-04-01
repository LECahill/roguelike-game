extends Node2D

@onready var movement_component: MovementComponent = %MovementComponent


const TILE_SIZE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TurnManager.player = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func try_move(direction: Vector2i) -> bool:
	return movement_component.try_move(direction)
	
