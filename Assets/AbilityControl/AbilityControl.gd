## This component provides the UI for the AbilityData 
class_name AbilityControl extends Control

const capacity_placeholder = preload("res://Assets/AbilityControl/DicePlaceHolder.tscn")

@export var data: AbilityData
@export var _name: Label
@export var _flavor: Label
@export var _cost: Label
@export var _description: Label
@export var _move_to_button: Button
@export var _cost_container: Container

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
	for d in Utils.get_children_with_tag(_cost_container, "DiceControl"):
		if d is DiceControl:
			diceControls.append(d)
	return diceControls

func _ready():
	add_to_group("AbilityControl")
	
	assert(data)
	assert(_name)
	assert(_cost)
	assert(_description)
	assert(_move_to_button)
	assert(_cost_container)
	
	# Signals
	_move_to_button.pressed.connect(_on_move_to_pressed)
	Signals.dice_moved_to_ability.connect(_on_dice_moved)
	Signals.dice_selected.connect(_on_dice_selected)
	Signals.dice_deselected.connect(_on_dice_deselected)
	Signals.dice_freed.connect(_on_dice_freed)
	
	_update_ui()

func _on_dice_freed(dc: DiceControl):
	_update_ui()

func _on_dice_moved(dc: DiceControl):
	_update_ui()

func _update_ui():
	if (data == null): return
	
	_name.text = data.name
	_cost.text = "Dice Total ≥ %s" % data.cost
	#region Update cost container
	var placeholder_dice_in_ability = _cost_container.get_children().filter(func(d): return d is not DiceControl)
	var dice_in_ability = get_associated_dice()
	for placeholder in placeholder_dice_in_ability:
		self.remove_child(placeholder)
		placeholder.queue_free()
	for i in data.capacity - dice_in_ability.size():
		_cost_container.add_child(capacity_placeholder.instantiate())
	#endregion
	#region Update description
	_description.text = ""
	if (data.damage):
		_description.text += "%s" % data.damage.get_message()
	if (data.buff):
		_description.text += "%s" % data.buff.get_message()
	if (data.overflow):
		_description.text += "Overflow: %s" % data.overflow.name
	#endregion
	
	if (_flavor):
		if (data.flavor):
			_flavor.text = "%s" % data.flavor
		else:
			_flavor.hide()

func _on_dice_selected(diceControl: DiceControl):
	_move_to_button.show()

func _on_dice_deselected(diceControl: DiceControl):
	_move_to_button.hide()

## When the move
func _on_move_to_pressed():
	if (Game.get_battle_manager().get_turn() != BattleManager.Turn.PLAYER):
		return
	
	var selected = Game.get_battle_manager().get_selected_dice()
	if !selected: return
	
	var ability = data
	var dice_in_ability =  _cost_container.get_children().filter(func(d): return d is DiceControl)
	var current_capacity = dice_in_ability.size()
	var max_capacity = ability.capacity
	
	if (current_capacity+1 > max_capacity):
		return
	
	selected.get_parent().remove_child(selected)
	_cost_container.add_child(selected)
	
	selected.deselect()
	Signals.dice_moved_to_ability.emit(selected)
