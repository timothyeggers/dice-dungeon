class_name EnemyControl extends Control

@export var _receiver: DamageReceiver
@export var _abilities: Array[AbilityComponent] = []
@export var _name:Label
@export var _health: Label
@export var _shield: Label
@export var _portrait: TextureRect
@export var _intention: TextureRect

var is_dead = false

var _ability_index = 0

static func create(data: DamageReceiverParameter, abilities: Array[AbilityComponent], portrait: Texture2D) -> EnemyControl:
	var scene = load("res://Assets/Enemy/EnemyControl.tscn")
	var control: EnemyControl = scene.instantiate()
	control._receiver.data = data
	for ability in abilities:
		control._abilities.append(ability)
	return control

func _ready():
	add_to_group("EnemyControl")
	
	assert(_receiver, "DamageReceiverComponent is required.")
	
	Game.end_turn.connect(_start_turn)
	_receiver.damage_received.connect(_update_ui)
	_receiver.buff_received.connect(_update_ui)
	
	_update_ui()

func _start_turn():
	var ability = _abilities[_ability_index]
	
	if (ability):
		ability.invoke(_receiver, Game.get_player())
	
	if _ability_index+1 < _abilities.size():
		_ability_index += 1
	else:
		_ability_index = 0

func _update_ui():
	var status = _receiver.get_status()
	_health.text = "Health: %s" % [status.health]
	_shield.text = "Shield: %s" % [status.shield]
