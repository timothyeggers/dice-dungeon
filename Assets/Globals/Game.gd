extends Node

## Emitted at the end of the start player turn function
signal player_start_turn
## Emitted at the end of end player turn function
signal player_end_turn
## Emitted at the end of start enemy turn function
signal enemy_start_turn
## Emitted at the end of end enemy turn function
signal enemy_end_turn

var _selected_target: DamageReceiverComponent
var _selected_dice: DiceControl
var _hand_capacity := 2

enum Turn_ID {
	PLAYER,
	NPC
}

var _turns := 0
var _current_turn := Turn_ID.PLAYER
var _player: Node

var _reserve_container: Container


func _ready():
	var endTurnButton = get_tree().get_first_node_in_group("End Turn Button") as Button
	endTurnButton.pressed.connect(end_player_turn)
	
	var reserveButton = get_tree().get_first_node_in_group("ReserveButton") as Button
	reserveButton.pressed.connect(reserve_selected_dice)
	
	_reserve_container = get_tree().get_first_node_in_group("ReserveContainer") as Container
	
	start_game()

func reserve_selected_dice():
	var selected = get_selected_dice()
	
	if (!selected): return
	
	var current_capacity = _reserve_container.get_children().size()
	var max_capacity = 2
	
	if (current_capacity+1 > max_capacity):
		return
	
	if (selected is DiceControl):
		selected.get_parent().remove_child(selected)
		_reserve_container.add_child(selected)

func select_target(component: DamageReceiverComponent):
	_selected_target = component

func create_player():
	var playerStats = load("res://Assets/DamageReceiverData/Player/PlayerStats.tres")
	var playerAbilities : Array[AbilityData] = [Ability.wrecklessSwing, Ability.steadfast, Ability.stab, Ability.wtf]
	
	# Add player abilities
	var field = get_tree().get_first_node_in_group("Field Container")
	var abilityContainer = get_tree().get_first_node_in_group("Ability Container")
	if (field):
		# Create player
		var player = PlayerControl.create(playerStats, field)
		
		# Create player abilities and UI
		for ability in playerAbilities:
			AbilityControl.create(ability, abilityContainer)
			Ability.register(player.get_instance_id(), ability)
		
		_player = player

func start_game():
	var field = get_tree().get_first_node_in_group("NPC Container")
	
	var enemies = [
		EnemyControl.create(EnemyManager.goblinStats, field, EnemyManager.goblinPortrait),
		EnemyControl.create(EnemyManager.goblinStats, field, EnemyManager.goblinPortrait),
		EnemyControl.create(EnemyManager.goblinStats, field, EnemyManager.goblinPortrait)
	]
	
	for e in enemies:
		Ability.register_multiple(e.get_instance_id(), Ability.get_goblin_abilities())
	
	create_player()
	
	match _current_turn:
		Turn_ID.PLAYER:
			call_deferred("start_player_turn")
		_:
			call_deferred("start_enemy_turn")


func get_turn_side() -> Turn_ID:
	return _current_turn

func end_game():
	get_tree().reload_current_scene()

func start_player_turn():
	_current_turn = Turn_ID.PLAYER
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Player Turn"
	
	for i in get_hand_capacity():
		draw_to_hand()
	
	player_start_turn.emit()


func end_player_turn():
	if _current_turn != Turn_ID.PLAYER:
		return
	
	var all_ability_controls: Array[AbilityControl]
	for n in get_tree().get_nodes_in_group("AbilityControl"):
		if n is AbilityControl:
			all_ability_controls.append(n)
	
	# Attempt to invoke all abilities, remove DiceControl from AbilityControl
	for i in all_ability_controls.size():
		var control = all_ability_controls[i]
		var ability = control.get_ability()
		var diceControls = control.get_associated_dice()
		var diceData: Array[DiceData] = []
		
		# No dice, just skip this ability.
		if diceControls.size() == 0:
			continue
		
		for dc in diceControls:
			if dc.data && dc.data is DiceData:
				diceData.append(dc.data)
		
		var targets : Array[DamageReceiverComponent] = []
		var max_count = ability.max_targets
		var count = 0
		for t in EnemyManager.get_all_alive():
			print_debug("DEBUG Found Target: %s, ID: %s" % [t.get_damage_receiver().display_name, t.get_damage_receiver().get_instance_id()])
			targets.append(t.get_damage_receiver())
			count += 1
			if count >= ability.max_targets:
				break
		
		print_debug("INFO Number of targets: %s" % targets.size())
		
		Ability.invoke(_player.get_instance_id(), diceData, get_player(), targets, i)
	
	# Get dice in Reserve
	for dc in _reserve_container.get_children():
		if dc is not DiceControl: continue
		get_player().receive_buff(BuffData.init(dc.data.value, 0, 0))
	
	# Remove all DiceControl
	for dc in get_tree().get_nodes_in_group("DiceControl"):
		dc.remove_from_group("DiceControl")
		dc.queue_free()
	
	# Tick all managers
	DamageReceiverManager.tick()
	
	player_end_turn.emit()
	
	start_enemy_turn()

func start_enemy_turn():
	_current_turn = Turn_ID.NPC
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Enemy Turn"
	
	enemy_start_turn.emit()
	
	end_enemy_turn()

func end_enemy_turn():
	if _current_turn != Turn_ID.NPC:
		return
	
	var enemies = EnemyManager.get_all_alive()
	var targets: Array[DamageReceiverComponent] = [get_player()]
	
	for enemy in enemies:
		var abilities = Ability.get_abilities(enemy.get_instance_id())
		if !abilities: 
			continue
		
		var index = Ability.get_invoked_ability_index(enemy.get_instance_id()) + 1
		
		print ("INFO %s is alive!  They have %s abilities!  They rolled %s ability" % [enemy.get_damage_receiver().display_name, abilities.size(), index])
		Ability.invoke(enemy.get_instance_id(), [DiceData.init(99)], enemy.get_damage_receiver(), targets, index)
	
	enemy_end_turn.emit()
	
	await get_tree().create_timer(1).timeout
	
	# Increment turn counter
	_turns += 1
	start_player_turn()

func get_selected_dice() -> DiceControl:
	return _selected_dice

func select_dice(dice: DiceControl):
	_selected_dice = dice

func get_hand_capacity() -> int:
	return _hand_capacity

func get_hand_size() -> int:
	var all_dice = get_tree().get_nodes_in_group("DiceControl")
	return all_dice.size()

## Creates a DiceControl, its associated DiceData value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		var hand = get_tree().get_first_node_in_group("Hand Container")
		
		var control = DiceControl.create(DiceData.init(), hand)

func get_player() -> DamageReceiverComponent:
	var player = get_tree().get_first_node_in_group("PlayerControl")
	var dr = Utils.get_first_child_with_tag(player, "DamageReceiverComponent")
	return dr

func get_target() -> DamageReceiverComponent:
	var enemy = get_tree().get_first_node_in_group("EnemyControl")
	var dr = Utils.get_first_child_with_tag(enemy, "DamageReceiverComponent")
	return dr
