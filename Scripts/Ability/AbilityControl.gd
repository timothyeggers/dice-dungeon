class_name AbilityControl extends Control

const scene = preload("res://Assets/Ability/AbilityControl.tscn")

@export var ability: Ability

static func create(ability: Ability) -> AbilityControl:
	var control: AbilityControl = scene.instantiate()
	control.ability = ability
	return control

func _ready():
	add_to_group("ability")
	
	var name = get_node("Panel/Container/Name") as Label
	var flavor = get_node("Panel/Container/Flavor") as Label
	var cost = get_node("Panel/Container/Ability/Cost/Icon") as TextureRect
	var description = get_node("Panel/Container/Ability/Description")
	
	if (name):
		name.text = ability.name
	
	if (flavor):
		flavor.text = ability.flavor_text
	
	if (description):
		description.text = ability.description
	
	if (cost):
		var cost_texture = "res://Assets/Dice/dice_number_%s.png"
		cost.texture = load(cost_texture  % ability.cost)
	
