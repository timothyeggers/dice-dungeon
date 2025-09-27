## This component provides the UI for the AbilityData 
class_name AbilityControl extends Control

@export var data: AbilityData
@export var _name: Label
@export var _capacity: Label
@export var _flavor: Label
@export var _cost: Label
@export var _description: Label
@export var _activate: Button
@export var cost_container: Container

static func create(ability: AbilityData, attach_to: Node) -> AbilityControl:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/AbilityControl/AbilityControl.tscn")
	var control = scene.instantiate()
	control.data = ability
	
	attach_to.add_child(control)
	
	return control

##  Returns a REFERENCE to the AbilityData, not the 'value'.
func get_ability() -> AbilityData:
	return data

func get_associated_dice() -> Array[DiceControl]:
	var diceControls : Array[DiceControl] = []
	for d in Utils.get_children_with_tag(self, "DiceControl"):
		if d is DiceControl:
			diceControls.append(d)
	return diceControls

func _ready():
	add_to_group("AbilityControl")
	
	_activate.pressed.connect(activate)
	
	_update_ui()

func _update_ui():
	
	if (data == null): return
	
	if (_name):
		_name.text = data.name
	
	if (_cost):
		_cost.text = "Cost ≥ %s" % data.cost
	
	if (_flavor):
		if (data.flavor):
			_flavor.text = "%s" % data.flavor
		else:
			_flavor.hide()
	
	if (_capacity):
		_capacity.text = "Capacity: %s" % data.capacity
	
	if (_description):
		if (data):
			_description.text = ""
			if (data.damage):
				_description.text += "%s" % data.damage.get_message()
			if (data.buff):
				_description.text += "%s" % data.buff.get_message()
			if (data.overflow):
				_description.text += "Overflow: %s" % data.overflow.name
		else:
			_description.text = ""

func activate():
	if (Game.get_battle_manager().get_turn() != BattleManager.Turn.PLAYER):
		return
	
	var selected = Game.get_battle_manager().get_selected_dice()
	if !selected: return
	
	var ability = data
	
	if (!selected): return
	if (!ability): return
	
	var dice_in_ability = cost_container.get_children()
	var current_capacity = dice_in_ability.size() #Utils.get_children_of_type(self, "DiceControl")
	var max_capacity = ability.capacity
	
	if (current_capacity+1 > max_capacity):
		return
	
	selected.get_parent().remove_child(selected)
	cost_container.add_child(selected)
	
	selected.deselect()
