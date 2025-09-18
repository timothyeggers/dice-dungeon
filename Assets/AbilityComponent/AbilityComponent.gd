"""This component will evoke the assigned AbilityParameter."""
class_name AbilityComponent extends Node

@export var data: AbilityParameter

var _index = 0

func _ready():
	add_to_group("AbilityComponent")

static func create(ability: AbilityParameter) -> AbilityComponent:
	var scene = load("res://Assets/AbilityComponent/AbilityComponent.tscn")
	var c = scene.instantiate()
	c.data = ability
	
	return c

"""Get the ability at a given index of array, or index 0, or null."""
func get_ability() -> AbilityParameter:
	return data

"""Execute the current ability(s) tied to this invoker."""
func invoke(sender: DamageReceiver, target: DamageReceiver, override: AbilityParameter = null):
	print_debug("%s was invoked!" % data.name)
	var ability: AbilityParameter = override
	if (!override):
		ability = get_ability()
	
	if (ability is AttackAbilityParameter):
		Abilities.basic_attack(target, ability.damage)
		print("Is attack")
	
	if (ability is DefenseAbilityParameter):
		Abilities.basic_defensive(sender, ability.buff)
