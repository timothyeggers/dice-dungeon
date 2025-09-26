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
var _world: Node2D

enum Turn {
	PLAYER,
	NPC,
	# Things EXECUTING means they're post "end turn", but haven't switched turns yet.
	# Useful for performing actions after end turn, like target selection.
	PLAYER_EXECUTING,
	NPC_EXECUTING
}

var _turns := 0
var _current_turn := Turn.PLAYER
var _player: Node

var _reserve_container: Container


func _ready():
	var endTurnButton = get_tree().get_first_node_in_group("End Turn Button") as Button
	if (endTurnButton):
		endTurnButton.pressed.connect(end_player_turn)
	
	var reserveButton = get_tree().get_first_node_in_group("ReserveButton") as Button
	if (reserveButton):
		reserveButton.pressed.connect(reserve_selected_dice)
	
	_reserve_container = get_tree().get_first_node_in_group("ReserveContainer") as Container
	
	_world = get_tree().get_first_node_in_group("World")
	
	Signals.receiver_selected.connect(_on_gui_target_select)
	
	#start_game()

func get_world() -> Node2D:
	# Do a search for first node2d if it isnt set?
	return _world

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

func _on_gui_target_select(component: DamageReceiverComponent):
	select_target(component)

func select_target(component: DamageReceiverComponent):
	_selected_target = component

func selected_target() -> DamageReceiverComponent:
	return _selected_target

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
		Turn.PLAYER:
			call_deferred("start_player_turn")
		_:
			call_deferred("start_enemy_turn")


func get_turn() -> Turn:
	return _current_turn

func end_game():
	get_tree().reload_current_scene()

func start_player_turn():
	_turns += 1
	_current_turn = Turn.PLAYER
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Player Turn (Turn %s)" % _turns
	
	for i in get_hand_capacity():
		draw_to_hand()
	
	player_start_turn.emit()


func end_player_turn():
	if _current_turn != Turn.PLAYER:
		return
	
	_current_turn = Turn.PLAYER_EXECUTING
	
	# Get all the ability controls the player has.
	var all_ability_controls: Array[AbilityControl]
	for n in get_tree().get_nodes_in_group("AbilityControl"):
		if n is AbilityControl:
			all_ability_controls.append(n)
	
	# Attempt to invoke all abilities, remove DiceControl from AbilityControl
	for i in all_ability_controls.size():
		var control = all_ability_controls[i]
		var diceControls = control.get_associated_dice()
		
		# No dice, just skip this ability.
		if diceControls.size() == 0:
			continue
		
		# Fill out ability with Data
		var ability = control.get_ability()
		var diceData: Array[DiceData] = []
		
		for dc in diceControls:
			if dc.data && dc.data is DiceData:
				diceData.append(dc.data.duplicate())
				dc.data = null
		
		# Select target(s)
		var targets : Array[DamageReceiverComponent] = []
		
		# Draw target selector, and select targets.
		if ability.damage:
			var selectors : Array[TargetSelector] = []
			for t in ability.max_targets:
				var sel = TargetSelector.create(control.get_global_rect().get_center(), get_world())
				selectors.append(sel)
				await Signals.receiver_selected
				targets.append(_selected_target)
				_selected_target = null
				sel.process_mode = Node.PROCESS_MODE_DISABLED
			for s in selectors:
				s.queue_free()
		
		print_debug("INFO Number of targets: %s" % targets.size())
		
		Ability.invoke(_player.get_instance_id(), diceData, get_player(), targets, i)
	
	# Get dice in Reserve, convert to shield.
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
	_current_turn = Turn.NPC
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Enemy Turn (Turn %s)" % _turns
	
	enemy_start_turn.emit()
	
	end_enemy_turn()

func end_enemy_turn():
	if _current_turn != Turn.NPC:
		return
	
	_current_turn = Turn.NPC_EXECUTING
	
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
