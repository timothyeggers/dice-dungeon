class_name EnemyControl extends Control

const scene = preload("res://Assets/Enemy/Component/EnemyControl.tscn")

@export var _receiver: DamageReceiver
@export var _invoker: AbilityInvoker
@export var _name:Label
@export var _health: Label
@export var _shield: Label
@export var _portrait: TextureRect
@export var _intention: TextureRect

var is_dead = false

static func create(data: DamageReceiverParameter, abilities: Array[AbilityParameter], portrait: Texture2D) -> EnemyControl:
	var control: EnemyControl = scene.instantiate()
	control._receiver.data = data
	control._invoker.data = abilities
	return control

func _ready():
	add_to_group("control_enemy")
	
	_receiver.damage_received.connect(_update_ui)
	_receiver.buff_received.connect(_update_ui)
	
	_update_ui(_receiver.data)

func _update_ui(parameter):
	var status = _receiver.get_status()
	_health.text = "Health: %s" % [status.health]
	_shield.text = "Shield: %s" % [status.shield]
