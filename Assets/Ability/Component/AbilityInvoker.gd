class_name AbilityInvoker extends Node

signal ability_invoked(AbilityParameter)

# Invoked in order
@export var data: Array[AbilityParameter]

var _index = 0

func _ready():
	add_to_group("AbilityInvoker")

"""Get the intended ability to invoke for this turn."""
func get_next() -> AbilityParameter:
	return data[_index]

func invoke(target: DamageReceiver, override: AbilityParameter = null):
	var ability: AbilityParameter = override
	if (!override):
		ability = data[_index]
		_index += 1
		if (_index >= data.size()): _index = 0
	
	if (ability is AttackAbilityParameter):
		Abilities.basic_attack(target, ability.damage)
