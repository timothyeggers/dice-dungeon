class_name DamageReceiver extends Node

signal damage_received()
signal buff_received()

@export var display_name := "Goblin"
@export var data: DamageReceiverParameter

var _active: DamageReceiverParameter

func _ready():
	add_to_group("DamageReceiver")
	
	_active = data.duplicate()

func buff(buff: BuffParameter):
	heal(buff.heal)
	regen(buff.regen)
	shield(buff.shield)
	buff_received.emit()

func heal(amount: int):
	_active.health += amount
	_active.health = max(0, _active.health)
	print("%s was healed for %s." % [display_name, amount])

func regen(amount: int):
	_active.regen += amount
	print("%s had %s regen applied!" % [display_name, amount])

func shield(amount: int):
	_active.shield += amount
	print("%s has gained %s shield." % [display_name, amount])

func receive(dmg: DamageParameter):
	var total_damage = 0
	
	if (!dmg.ignore_armor):
		print("%s absorbed damage to shield!" % [display_name])
		_active.shield -= dmg.amount
		if _active.shield < 0:
			total_damage += abs(_active.shield)
			_active.shield = 0
	else:
		total_damage += dmg.amount
	total_damage += (1-_active.fire_resistance) * dmg.fire_damage 
	total_damage += (1-_active.lightning_resistance) * dmg.lightning_damage 
	total_damage += dmg.dark_damage
	
	_active.health -= total_damage
	
	print("%s has taken %s damage!" % [display_name, total_damage])
	damage_received.emit(_active)

func get_status() -> DamageReceiverParameter:
	return _active.duplicate()
