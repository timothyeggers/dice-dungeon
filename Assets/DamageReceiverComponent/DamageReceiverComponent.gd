class_name DamageReceiverComponent extends Node

signal damage_received()
signal buff_received()

@export var display_name := "Goblin"
@export var data: DamageReceiverData

var _data: DamageReceiverData

func _ready():
	add_to_group("DamageReceiverComponent")
	
	_data = data.duplicate()

func _enter_tree() -> void:
	DamageReceiverManager.add(self)

func _exit_tree() -> void:
	DamageReceiverManager.remove(self)

## Tick the debuffs/buffs on this receiver 
func tick():
	if _data.decay:
		_data.shield -= _data.decay
		_data.shield = max(0, _data.shield)
		_data.decay -= 1
	
	if _data.regen:
		_data.health += _data.regen
		_data.regen -= 1
	
	damage_received.emit()
	buff_received.emit()

func receive(dmg: DamageData):
	var total_damage = 0
	
	var current_shield = _data.shield
	
	if (!dmg.ignore_armor):
		_data.shield -= dmg.amount
		if _data.shield < 0:
			total_damage += abs(_data.shield)
			_data.shield = 0
	else:
		total_damage += dmg.amount
	
	total_damage += (1-_data.fire_resistance) * dmg.fire_damage 
	total_damage += (1-_data.lightning_resistance) * dmg.lightning_damage 
	total_damage += dmg.dark_damage 
	
	var hit_chance = PseudoRandom.get_random()
	print_debug("DEBUG Final hit_chance: %s" % hit_chance)
	if (1-dmg.accuracy) > hit_chance:
		total_damage = 0
	
	_data.health -= total_damage
	_data.decay += dmg.decay
	
	print_debug("INFO %s absorbed %s damage to shield!" % [display_name, abs(current_shield-_data.shield)])
	print_debug("INFO %s has taken %s damage!" % [display_name, total_damage])
	
	damage_received.emit()

func receive_buff(buff: BuffData):
	_data.health += buff.heal
	_data.health = max(0, _data.health)
	_data.regen += buff.regen
	_data.shield += buff.shield
	_data.shield = max(0, buff.shield)
	
	print_debug("INFO %s was healed for %s." % [display_name, buff.heal])
	print_debug("INFO %s had %s regen applied!" % [display_name, buff.regen])
	print_debug("INFO %s has gained %s shield." % [display_name, buff.shield])
	
	buff_received.emit()

func get_status() -> DamageReceiverData:
	return _data.duplicate()
