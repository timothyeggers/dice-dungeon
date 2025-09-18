"""This component displays the UI for the AbilityComponent. """
class_name AbilityControl extends Control

@export var _component: AbilityComponent
@export var _receiver: DamageReceiver
@export var _name: Label
@export var _flavor: Label
@export var _cost: Label
@export var _description: Label
@export var _activate: Button
@export var cost_container: Container

static func create(ability: AbilityData) -> AbilityControl:
	var scene = load("res://Assets/AbilityControl/AbilityControl.tscn")
	var control = scene.instantiate()
	control._component.data = ability
	return control

"""Returns the AbilityComponent that this UI represents."""
func get_component() -> AbilityComponent:
	return _component

func get_receiver() -> DamageReceiver:
	return _receiver

"""A wrapper that returns this AbilityComponent.AbilityData on the """
func get_ability():
	return _component.get_ability()

func get_associated_dice() -> Array:
	return Utils.get_children_with_tag(self, "DiceControl")

func _ready():
	add_to_group("AbilityControl")
	
	assert(_component, "AbilityComponent is a required component.")
	
	Game.end_turn.connect(_end_turn)
	_activate.pressed.connect(activate)
	
	_update_ui()

func _end_turn():
	var these_dice = get_associated_dice()
	
	var total = 0
	for dice in these_dice:
		total += dice.data.value
	
	if (total >= _component.data.cost):
		_component.invoke(Game.get_player(), Game.get_target())

func _update_ui():
	
	var data = _component.get_ability()
	
	if (data == null): return
	
	if (_name):
		_name.text = data.name
	
	if (_cost):
		_cost.text = "Cost ≥ %s" % data.cost
	
	if (_flavor):
		_flavor.text = data.flavor
	
	if (_description):
		_description.text = data.tooltip

func activate():
	var selected = Game.get_selected_dice()
	var ability = _component.get_ability()
	
	if (!selected): return
	if (!ability): return
	
	var dice_in_ability = cost_container.get_children()
	var current_capacity = dice_in_ability.size() #Utils.get_children_of_type(self, "DiceControl")
	var max_capacity = ability.capacity
	
	if (current_capacity+1 > max_capacity):
		return
	
	if (selected is DiceControl):
		selected.get_parent().remove_child(selected)
		cost_container.add_child(selected)

#func _on_end_turn():
	#var dice_in_ability = cost_container.get_children()
	#var cost_filled = 0
	#for dice in dice_in_ability:
		#cost_filled += dice.data.value
	#
	#if (cost_filled >= _component.data[0].cost):
		#_component.invoke(get_tree().get_first_node_in_group("DamageReceiver"))
