class_name DamageReceiverComponent extends Node

signal damage_received(damage_data)
signal buff_received(buff_data)

@export var display_name := "Empty"
@export var data: DamageReceiverData

var _data: DamageReceiverData
## This is set to _data when receive_damage or receive_buff is called.
var _previous_data: DamageReceiverData

func _ready():
	add_to_group("DamageReceiverComponent")

func _enter_tree() -> void:
	DamageReceiverManager.add(self)
	
	_data = data.duplicate()

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
	_previous_data = _data.duplicate()
	var inflicted = DamageData.init(0)
	
	var hit_chance = PseudoRandom.get_random()
	print_debug("DEBUG Final hit_chance: %s" % hit_chance)
	if (1-dmg.accuracy) <= hit_chance:
		if (!dmg.ignore_armor):
			_data.shield -= dmg.amount
			if _data.shield < 0:
				inflicted.amount += abs(_data.shield)
				_data.shield = 0
		else:
			inflicted.amount += dmg.amount
		
		inflicted.fire_damage += (1-_data.fire_resistance) * dmg.fire_damage 
		inflicted.lightning_damage += (1-_data.lightning_resistance) * dmg.lightning_damage 
		inflicted.dark_damage += dmg.dark_damage
		
		inflicted.decay += dmg.decay
	else:
		# missed target.
		var control = find_parent("EnemyControl")
		if control && control is EnemyControl:
			print_debug("DEBUG Missed target!")
			UI.create_floating_label(control.get_instance_id(), "Miss!", 0, control.get_global_center(), Game.get_world(), Color.RED)
	
	_data.health -= inflicted.get_total_raw()
	_data.decay += inflicted.decay
	
	print_debug("INFO %s absorbed %s damage to shield!" % [display_name, abs(_previous_data.shield-_data.shield)])
	print_debug("INFO %s has taken %s damage to health!" % [display_name, inflicted.get_total_raw()])
	
	damage_received.emit(inflicted)

func receive_buff(buff: BuffData):
	_previous_data = _data.duplicate()
	_data.health += buff.heal
	_data.health = max(0, _data.health)
	_data.regen += buff.regen
	_data.shield += buff.shield
	_data.shield = clamp(_data.shield, 0, _data.shield)
	
	print_debug("INFO %s was healed for %s." % [display_name, buff.heal])
	print_debug("INFO %s had %s regen applied!" % [display_name, buff.regen])
	print_debug("INFO %s has gained %s shield." % [display_name, buff.shield])
	
	buff_received.emit(buff)

func get_previous_status() -> DamageReceiverData:
	return _previous_data

func get_status() -> DamageReceiverData:
	return _data
