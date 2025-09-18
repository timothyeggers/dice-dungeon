class_name PlayerControl extends Control

signal death

# Load pre-requisite UI into Game memory.
@export var _receiver: DamageReceiverComponent
@export var _status: Label
@export var _name: Label
@export var _health: Label
@export var _shield: Label

var _in_hand: Array[DiceData] = []
var _hand_capacity: int

var is_dead = false

static func create(data: DamageReceiverData, portrait: Texture2D = null) -> PlayerControl:
	var scene = load("res://Assets/PlayerControl/PlayerControl.tscn")
	
	var control: PlayerControl = scene.instantiate()
	control._receiver.data = data
	
	return control

func _ready():
	add_to_group("PlayerControl")
	
	Game.player_end_turn.connect(_turn_end)
	
	_receiver.damage_received.connect(_update_ui)
	_receiver.buff_received.connect(_update_ui)
	
	_update_ui()

func _turn_end():
	pass

func _update_ui():
	var status = _receiver.get_status()
	
	_health.text = "Health: %s" % [status.health]
	_shield.text = "Shield: %s" % [status.shield]
	
	if _status:
		var message = ""
		if (status.regen):
			message += "Regen: %s\n" % status.regen
		if (status.decay):
			message += "Decay: %s\n" % status.decay
		
		_status.text = message
	
	if status.health <= 0:
		death.emit()

#var enemies_killed = 0
#
#var _selected_dice: DiceControl
#
#func selected_dice() -> DiceControl:
	#return _selected_dice
#
#func select_dice(diceControl: DiceControl):
	#_selected_dice = diceControl
#
#func get_all_dice() -> Array:
	#var dice = get_tree().get_nodes_in_group("control_dice")
	#return dice
#
##region Moving DiceData
#func move_to_hand():
	#if (selected_dice()):
		#if (hand):
			#selected_dice().get_parent().remove_child(selected_dice())
			#hand.add_child(selected_dice())
#
#func move_all_to_hand():
	#for dice in get_all_dice():
		#if (hand):
			#dice.get_parent().remove_child(dice)
			#hand.add_child(dice)
			#select_dice(null)
#
#
#func move_to_reserve():
	#if (selected_dice()):
		#if (reserve):
			#if Utils.get_children_with_tag(reserve, "control_dice").size() < reserve_capacity:
				#selected_dice().get_parent().remove_child(selected_dice())
				#reserve.add_child(selected_dice())
				#var in_reserve : Array = get_all_dice().filter(in_reserve)
				#var total = 0
				#for r in in_reserve:
					#total += r.dice.value
				#
				#shield_label.text = "Shield: %s (+%s)" % [shield, ceil(total / 2.0)]
				#
				#select_dice(null)
			#else:
				#print_terminal("You've exceeded the dice reserve capacity.")
##endregion
#
#func get_hand_capacity() -> int:
	#return _hand_capacity
#
#func get_hand_size() -> int:
	#var all_dice = get_tree().get_nodes_in_group("control_dice")
	#return all_dice.size()
#
#
#func in_reserve(dice: DiceControl):
	#if dice.get_parent() == reserve:
		#return true
	#return false
#
#
### Creates a DiceControl, its associated DiceData value, and adds the DiceControl to the Hand UI.
#func draw_to_hand():
	#if get_hand_size() < get_hand_capacity():
		## Randomize this eventually?
		#var control = create_dice()
		#
		#_in_hand.append(control.data)
		#
		## Add DiceControl to Hand UI.
		#if (hand):
			#hand.add_child(control)
			#
#func take_damage(params: DamageData):
	#var delta = shield - params.amount
	#decay += params.decay
	#shield -= params.amount
	#if (delta <= 0):
		#health += delta
	#print_terminal("Dealed %s damage to player." % params.amount)
	#print_terminal("Dealed %s damage to player health." % abs(delta))
	#print_terminal("Applied %s decay to player." % params.decay)
