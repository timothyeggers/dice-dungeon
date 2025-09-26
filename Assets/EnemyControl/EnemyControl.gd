class_name EnemyControl extends Control

signal death

const _attackIntention = preload("res://Assets/Icons/dagger_thumbnail.png")
const _defendIntention = preload("res://Assets/Icons/shield_thumbnail.png")
const _specialIntention = preload("res://Assets/Icons/unknown_thumbnail.png")
const _pierceArmorIntention = preload("res://Assets/Icons/shield_pierced_thumbnail.png")

@export var _receiver: DamageReceiverComponent
#@export var _abilities: Array[AbilityComponent] = []
@export var _name: Button
@export var _health: Label
@export var _shield: Label
@export var _portrait: TextureRect
@export var _intention_attack: TextureRect
@export var _intention_defend: TextureRect
@export var _intention_unknown: TextureRect

var _ability_index = 0
var _is_dead = false

#  abilities: Array[AbilityComponent], 
static func create(data: DamageReceiverData, attach_to: Node, portrait: Texture2D = null) -> EnemyControl:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/EnemyControl/EnemyControl.tscn")
	var control: EnemyControl = scene.instantiate()
	control._receiver.data = data
	if (control._portrait && portrait):
		control._portrait.texture = portrait
	
	attach_to.add_child(control)
	
	return control

func get_damage_receiver() -> DamageReceiverComponent:
	return _receiver

func _ready():
	add_to_group("EnemyControl")
	
	assert(_receiver, "DamageReceiverComponent is required.")
	
	Game.player_start_turn.connect(_update_ui)
	Game.player_start_turn.connect(_update_intention_ui)
	
	death.connect(_on_death)
	_name.pressed.connect(_on_enemy_select)
	
	_receiver.damage_received.connect(_update_ui)
	_receiver.buff_received.connect(_update_ui)
	
	_update_ui()

func _enter_tree() -> void:
	EnemyManager.add(get_instance_id())

func _exit_tree() -> void:
	EnemyManager.remove(get_instance_id())

func _on_enemy_select():
	Signals.receiver_selected.emit(_receiver)

func _on_death():
	_is_dead = true
	queue_free()

## If EnemyControl is queued for deletion return false.
func is_alive() -> bool:
	if is_queued_for_deletion():
		return false
	return true

func _update_intention_ui():
	var i = Ability.get_invoked_ability_index(get_instance_id()) + 1
	var ability = Ability.get_ability(get_instance_id(), i)
	if ability is not AbilityData:
		return
	_intention_attack.texture = null
	_intention_defend.texture = null
	if ability.damage:
		_intention_attack.texture = _attackIntention
		if ability.damage.ignore_armor:
			_intention_attack.texture = _pierceArmorIntention
	if ability.buff:
		_intention_defend.texture = _defendIntention

func _update_ui():
	var status = _receiver.get_status()
	_health.text = "Health: %s" % [status.health]
	_shield.text = "Shield: %s" % [status.shield]
	if status.decay > 0:
		_shield.text += " (-%s)" % status.decay
	_name.text = _receiver.display_name
	
	if status.health <= 0:
		death.emit()
