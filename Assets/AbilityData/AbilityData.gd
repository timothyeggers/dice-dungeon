## Resource providing the data behind damage and buffs.
class_name AbilityData extends Resource

## I'm thinking AbilityData.Type determines how extra dice cost affect abilities.
# For example, 
# Dexterity dice value greater than requirement adds extra shield.
# Intellect dice value greater than requirement adds extra value as a separate dice to the overflow.
# Strength dice value greater than requirement adds extra damage per extra number value.
enum Type {
	STRENGTH,
	DEXTERITY,
	INTELLECT,
	OVERFLOW
}

func get_type_display_name() -> String:
	match type:
		Type.STRENGTH:
			return "Strength"
		Type.DEXTERITY:
			return "Dexterity"
		Type.INTELLECT:
			return "Intellect"
		_:
			return "???"


@export var name := "Empty"
@export var flavor := ""
@export var type := Type.STRENGTH
@export var cost := 0
@export var capacity := 1
@export var max_targets := 1
@export var damage : DamageData
@export var buff : BuffData
## If there's an overflow, activate it if there's extra capacity at 50% cost.
@export var overflow: AbilityData
