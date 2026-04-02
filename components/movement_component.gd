class_name MovementComponent extends Node

var grid_position = Vector2i.ZERO

const TILE_SIZE = 32

func _ready() -> void:
	get_parent().position = Vector2(grid_position * TILE_SIZE)

func try_move(direction: Vector2i) -> bool:
	var target = grid_position + direction
	if DungeonManager.grid[target.y][target.x] == 0 and !TurnManager.is_tile_occupied(target):
		grid_position = target
		get_parent().position = Vector2(target * TILE_SIZE)
		return true
	return false
