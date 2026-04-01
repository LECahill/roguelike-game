extends Node

@export var player: Node2D
@export var enemies = []

enum GameState {
	WAITING_FOR_INPUT,
	PROCESSING_PLAYER,
	PROCESSING_ENEMIES,
	PROCESSING_ENVIRONMENT
}

var currentState = GameState.WAITING_FOR_INPUT

func _process(delta: float) -> void:
	match currentState:
		GameState.WAITING_FOR_INPUT:
			var direction = Vector2i.ZERO
			if Input.is_action_just_pressed("move_up"):
				direction = (Vector2i(0, -1))
			elif Input.is_action_just_pressed("move_down"):
				direction = (Vector2i(0, 1))
			elif Input.is_action_just_pressed("move_left"):
				direction = (Vector2i(-1, 0))
			elif Input.is_action_just_pressed("move_right"):
				direction = (Vector2i(1,0))
			
			if direction != Vector2i.ZERO:
				var took_action = false
				if player.try_move(direction):
					took_action = true
				else:
					var target_enemy = get_enemy_at(player.movement_component.grid_position + direction)
					if target_enemy: #not null, there is enemy
						target_enemy.health_component.take_damage(player.attack_component.attack())
						took_action = true
				if took_action:
					currentState = GameState.PROCESSING_PLAYER
		GameState.PROCESSING_PLAYER:
			currentState = GameState.PROCESSING_ENEMIES
		GameState.PROCESSING_ENEMIES:
			for enemy in enemies:
				var dir = enemy.calculate_direction()
				if enemy.try_move(dir):
					pass
				else:
					if enemy.is_adjacent_to_player():
						player.health_component.take_damage(enemy.attack_component.attack())
			currentState = GameState.PROCESSING_ENVIRONMENT
		GameState.PROCESSING_ENVIRONMENT:
			currentState = GameState.WAITING_FOR_INPUT

func is_tile_occupied(target_position: Vector2i) -> bool:
	if player.movement_component.grid_position == target_position:
		return true
	
	for enemy in enemies:
		if enemy.movement_component.grid_position == target_position:
			return true
	
	return false

func get_enemy_at(target_position: Vector2i):
	for enemy in enemies:
		if enemy.movement_component.grid_position == target_position:
			return enemy
	return null
