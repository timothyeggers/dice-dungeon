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

static func create(data: DamageReceiverData, attach_to: Node, portrait: Texture2D = null) -> PlayerControl:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/PlayerControl/PlayerControl.tscn")
	
	var control: PlayerControl = scene.instantiate()
	control._receiver.data = data
	
	attach_to.add_child(control)
	
	return control

func _ready():
	add_to_group("PlayerControl")
	
	_receiver.damage_received.connect(_update_ui)
	_receiver.buff_received.connect(_update_ui)
	
	_update_ui()

func _turn_end():
	_receiver.tick_buffs()

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
			_shield.text += " (-%s) decay" % status.decay
		
		_status.text = message
	
	if status.health <= 0:
		death.emit()
