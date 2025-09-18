class_name DamageReceiver extends Node

signal damage_received()
signal buff_received()

@export var display_name := "Goblin"
@export var data: DamageReceiverData

var _data: DamageReceiverData

func _ready():
	add_to_group("DamageReceiver")
	
	_data = data.duplicate()

func buff(buff: BuffData):
	heal(buff.heal)
	regen(buff.regen)
	shield(buff.shield)
	buff_received.emit()

func heal(amount: int):
	_data.health += amount
	_data.health = max(0, _data.health)
	print("%s was healed for %s." % [display_name, amount])

func regen(amount: int):
	_data.regen += amount
	print("%s had %s regen applied!" % [display_name, amount])

func shield(amount: int):
	_data.shield += amount
	print("%s has gained %s shield." % [display_name, amount])

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
	
	_data.health -= total_damage
	
	print("%s absorbed %s damage to shield!" % [display_name, abs(current_shield-_data.shield)])
	print("%s has taken %s damage!" % [display_name, total_damage])
	damage_received.emit()

func get_status() -> DamageReceiverData:
	return _data.duplicate()
