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
			if Input.is_action_just_pressed("move_up"):
				if player.try_move(Vector2i(0, -1)):
					currentState = GameState.PROCESSING_PLAYER
			elif Input.is_action_just_pressed("move_down"):
				if player.try_move(Vector2i(0, 1)):
					currentState = GameState.PROCESSING_PLAYER
			elif Input.is_action_just_pressed("move_left"):
				if player.try_move(Vector2i(-1, 0)):
					currentState = GameState.PROCESSING_PLAYER
			elif Input.is_action_just_pressed("move_right"):
				if player.try_move(Vector2i(1,0)):
					currentState = GameState.PROCESSING_PLAYER
		GameState.PROCESSING_PLAYER:
			currentState = GameState.PROCESSING_ENEMIES
		GameState.PROCESSING_ENEMIES:
			for enemy in enemies:
				var dir = enemy.calculate_direction()
				enemy.try_move(dir)
			currentState = GameState.PROCESSING_ENVIRONMENT
		GameState.PROCESSING_ENVIRONMENT:
			currentState = GameState.WAITING_FOR_INPUT
