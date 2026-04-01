class_name HealthComponent extends Node

signal died

@export var max_health: int
var current_health: int

func _ready():
	current_health = max_health

func take_damage(damage: int):
	current_health -= damage
	if current_health <= 0:
		die()
	
func heal(health: int):
	current_health += health
	if current_health >= max_health:
		current_health = max_health

func die():
	died.emit()
