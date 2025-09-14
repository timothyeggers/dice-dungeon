class_name AbilityControl extends Control

const scene = preload("res://Assets/Ability/AbilityControl.tscn")

@export var ability: Ability

var cost: Control

static func create(ability: Ability) -> AbilityControl:
	var control: AbilityControl = scene.instantiate()
	control.ability = ability
	return control

func _ready():
	add_to_group("ability")
	
	var name = get_node("Container/Name") as Label
	var flavor = get_node("Container/Flavor") as Label
	cost = get_node("Container/Ability/Cost") as Label
	var description = get_node("Container/Ability/Description")
	
	if (name):
		name.text = ability.name
	
	if (cost):
		cost.text = str(ability.cost)
	
	if (flavor):
		flavor.text = ability.flavor_text
	
	if (description):
		description.text = ability.description
	
