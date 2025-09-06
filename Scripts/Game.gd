extends Node

var _in_hand: Array[Dice] = []
var _hand_capacity: int

# game start
func _ready():
	_hand_capacity = 3

## Randomly creates a DiceControl and associated Dice.
func create_dice() -> DiceControl:
	var dice = Dice.create()
	var control = DiceControl.create(dice)
	
	return control

## Creates a DiceControl, its associated Dice value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		# Randomize this eventually?
		var control = create_dice()
		
		Signals.dice_registered.emit(control.dice)
		_in_hand.append(control.dice)
		
		# Add DiceControl to Hand UI.
		var hand = get_tree().get_first_node_in_group("ui_hand")
		hand.add_child(control)

func get_hand_capacity() -> int:
	return _hand_capacity

func get_hand_size() -> int:
	return _in_hand.size()
