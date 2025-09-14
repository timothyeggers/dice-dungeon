class_name EnemyStats extends Resource

@export var name: String
@export var abilities: Array[Ability]
@export var health: int:
	set(value):
		health = value
		current_health = value
@export var shield: int:
	set(value):
		shield = value
		current_shield = value
@export var portrait: Texture2D
@export var max_range: int = 3
@export var likelihood_to_attack = 0.7

var current_health
var current_shield
