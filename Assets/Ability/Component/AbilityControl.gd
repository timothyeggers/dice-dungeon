class_name AbilityControl extends Control

@export var _invoker: AbilityInvoker
@export var _name: Label
@export var _flavor: Label
@export var _cost: Label
@export var _description: Label
@export var _activate: Button
@export var cost_container: Container

static func create(ability: AbilityParameter) -> AbilityControl:
	var scene = load("res://Assets/Ability/Component/AbilityControl.tscn")
	var control: AbilityControl = scene.instantiate()
	control._invoker.data.append(ability)
	
	return control

func _ready():
	add_to_group("control_ability")
	
	Game.end_turn.connect(_on_end_turn)
	
	_activate.pressed.connect(activate)
	
	_update_ui(_invoker.data[0])

func _update_ui(data: AbilityParameter):
	if (_name):
		_name.text = data.name
	
	if (_cost):
		_cost.text = "Cost ≥ %s" % data.cost
	
	if (_flavor):
		_flavor.text = data.flavor
	
	if (_description):
		_description.text = data.tooltip

func activate():
	var selected = Game.selected_dice()
	
	if (!selected): return
	
	var dice_in_ability = cost_container.get_children()
	var current_capacity = dice_in_ability.size() #Utils.get_children_of_type(self, "DiceControl")
	var max_capacity = _invoker.data[0].capacity
	
	if (current_capacity+1 > max_capacity):
		return
	
	if (selected is DiceControl):
		selected.get_parent().remove_child(selected)
		cost_container.add_child(selected)

func _on_end_turn():
	var dice_in_ability = cost_container.get_children()
	var cost_filled = 0
	for dice in dice_in_ability:
		cost_filled += dice.data.value
	
	if (cost_filled >= _invoker.data[0].cost):
		_invoker.invoke(get_tree().get_first_node_in_group("DamageReceiver"))
