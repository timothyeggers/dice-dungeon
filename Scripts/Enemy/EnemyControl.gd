class_name EnemyControl extends Control

const scene = preload("res://Assets/Enemy/EnemyControl.tscn")

@export var stats: EnemyStats

var is_dead = false

var shield_ui
var health_ui

var health: int:
	set(value):
		value = max(0, value)
		health = value
		_update_health_ui()
var shield: int:
	set(value):
		value = max(0, value)
		shield = value
		_update_shield_ui()

static func create(stats: EnemyStats) -> EnemyControl:
	var control: EnemyControl = scene.instantiate()
	control.stats = stats
	return control

func _ready():
	add_to_group("stats")
	
	var name = get_node("Container/Name") as Label
	health_ui = get_node("Container/Health") as Label
	shield_ui = get_node("Container/Shield") as Label
	var portrait = get_node("Container/Portrait") as TextureRect
	
	if (name):
		name.text = stats.name
	
	if (health_ui):
		health_ui.text = "%s/%s" % [stats.current_health, stats.health]
	
	if (portrait):
		portrait.texture = stats.portrait
	
	health = stats.health
	shield = stats.shield

func _update_shield_ui():
	shield_ui.text = "Shield: %s" % shield

func _update_health_ui():
	health_ui.text = "Health: %s" % health

func perform():
	var value = randi_range(1, stats.max_range)
	var action = randf_range(0,1 )
	if action <= stats.likelihood_to_attack:
		var dmg = DamageParameter.new()
		var decay = randi_range(0, 2)
		dmg.amount = value
		dmg.decay = decay
		Game.enemy_action(self, Game.ActionType.ATTACK, dmg)
	else:
		shield += value
		

func take_damage(value):
	var diff = shield - value
	shield -= value
	health += diff
	print("%s took %s damage!" % [stats.name, value])
	if (health <= 0):
		print("Arr!! I died! %s" % stats.name)
		Game.enemies_killed += 1
		queue_free()
		is_dead = true

	#for ability in stats.abilities:
	#		var cost_texture = "res://Assets/Dice/dice_number_%s.png"
	#		cost.texture = load(cost_texture  % ability.cost)
	
