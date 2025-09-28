extends Node

## Contains a key of get_instance_id() of the Control and a AbilityData array of associated abilities.
var _abilities : Dictionary = {}

## Contains a key of get_instance_id() of the Control and a index value of the last used ability. Is 0 instantiated.
var _ability_last_use : Dictionary = {}

#region Offensive Abilities
const killAll = preload("res://Assets/AbilityData/Attacks/KillAll.tres")
const murkyStab = preload("res://Assets/AbilityData/Attacks/MurkyStab.tres")
const stab = preload("res://Assets/AbilityData/Attacks/Stab.tres")
const wrecklessSwing = preload("res://Assets/AbilityData/Attacks/WrecklessSwing.tres")
#endregion

#region Defense Abilities
const reinforce = preload("res://Assets/AbilityData/Defensives/Reinforce.tres")
const raiseShield = preload("res://Assets/AbilityData/Defensives/RaiseShield.tres")
const steadfast = preload("res://Assets/AbilityData/Defensives/Steadfast.tres")
const wtf = preload("res://Assets/AbilityData/Defensives/MaxHeal.tres")
#endregion

func register_multiple(owner_instance_id: int, abilities: Array[AbilityData]):
	for a in abilities:
		register(owner_instance_id, a)

## AbilityData is not tracked automatically, when you create an ability you need to register it with this call.
func register(owner_instance_id: int, ability: AbilityData):
	if _abilities.has(owner_instance_id):
		_abilities[owner_instance_id].append(ability)
	else:
		_abilities[owner_instance_id] = [ability]
		_ability_last_use[owner_instance_id] = null
	print_debug("DEBUG Added Ability: %s for Owner: %s" % [ability.name, owner_instance_id])

func deregister(owner_instance_id: int):
	if _abilities.has(owner_instance_id):
		_abilities.erase(owner_instance_id)
		_ability_last_use.erase(owner_instance_id)
		print_debug("DEBUG Removed %s instance from abilities list." % owner_instance_id)

## Removes keys in which an instance reference is not in tree.  This is probably not needed.
func clear():
	for key in _abilities.keys():
		if !get_tree().instance_from_id(key):
			deregister(key)

func get_abilities(for_id: int):
	if _abilities.has(for_id):
		return _abilities[for_id]

## Get the AbilityData bound to for_id, or the first element if no ability exists within the size.
func get_ability(for_id: int, index: int):
	if _abilities.has(for_id):
		if index < _abilities[for_id].size():
			return _abilities[for_id][index]
	return null

## Returns the index of the last invoked ability, or -1 if nothing has been invoked...
func get_invoked_ability_index(for_id: int):
	var index = -1
	if _ability_last_use.has(for_id):
		if _ability_last_use[for_id] != null:
			return _ability_last_use[for_id]
	return index

func invoke(owner_instance_id: int, dice: Array[DiceData], sender: DamageReceiverComponent, target: DamageReceiverComponent, index = 0, is_overflow := false):
	if !_abilities.has(owner_instance_id):
		return
		
	if _abilities[owner_instance_id].size() == 0:
		return
	
	if index >= _abilities[owner_instance_id].size():
		index = 0
	
	var ability: AbilityData = _abilities[owner_instance_id][index]
	if is_overflow:
		if ability.overflow == null:
			return
		ability = ability.overflow
	
	# If there's extra dice at the end of the function, we'll call invoke again with the extra_dice on the overflow ability.
	var extra_dice: Array[DiceData] = []
	var total = 0
	for d in dice:
		if total >= ability.cost:
			extra_dice.append(d)
		
		total += d.value
	
	if (total < ability.cost):
		return
	
	print_debug("INFO %s is invoking %s ability..." % [sender.display_name, ability.name])
	
	if (ability.damage):
		target.receive(ability.damage)
	
	if (ability.buff):
		sender.receive_buff(ability.buff)
	
	_ability_last_use[owner_instance_id] = index
	
	#if (extra_dice.size() > 0 && ability.overflow != null):
	#	invoke(owner_instance_id, extra_dice, sender, target, index, true)
