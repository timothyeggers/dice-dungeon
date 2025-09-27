class_name BattleManager extends Node

enum Turn {
	PLAYER,
	ENEMY,
	# Things EXECUTING means they're post "end turn", but haven't switched turns yet.
	# Useful for performing actions after end turn, like target selection.
	PLAYER_EXECUTING,
	ENEMY_EXECUTING
}

const max_enemies = 4

## Load this during Game.start_battle
var data := PathData.create_default()

var _current_turn := Turn.PLAYER
var _selected_target: DamageReceiverComponent
var _selected_dice: DiceControl
var _turns := 0
var _hand_capacity := 3
var _player: Node

# These two parameters are used for selecting Dice with scroll wheel.
var _dice_count_in_reserve = _hand_capacity
var _dice_in_reserve_selected_index = 0

@export var _end_turn_button: Button
@export var _reserve_button: Button
# Contains dice to be reserved
@export var _reserve_container: Container
# Contains PlayerControl
@export var _field_container: Container
# Contains AbilityControl
@export var _ability_container: Container
# Contains dice in hand
@export var _hand_container: Container
# Contains EnemyControl
@export var _enemy_container: Container


func _ready():
	assert(_end_turn_button)
	assert(_reserve_button)
	assert(_reserve_container)
	assert(_field_container)
	assert(_ability_container)
	assert(_hand_container)
	assert(_enemy_container)
	
	# Build Signal connects
	_reserve_button.pressed.connect(reserve_selected_dice)
	_end_turn_button.pressed.connect(_end_player_turn)
	Signals.receiver_selected.connect(_on_gui_target_select)
	Signals.dice_selected.connect(_on_dice_selected)
	Signals.dice_deselected.connect(_on_dice_deselected)
	
	_start()

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

func selected_target() -> DamageReceiverComponent:
	return _selected_target

func get_turn() -> Turn:
	return _current_turn

func get_selected_dice() -> DiceControl:
	return _selected_dice

func _on_dice_deselected(dice: DiceControl):
	Input.set_custom_mouse_cursor(null)
	
	if get_turn() != Turn.PLAYER:
		return
	
	_selected_dice = null

func _on_dice_selected(dice: DiceControl):
	if get_turn() != Turn.PLAYER: 
		return
	
	if dice == null:
		return
	
	Input.set_custom_mouse_cursor(dice.texture_focused)
	
	_selected_dice = dice

func get_hand_capacity() -> int:
	return _hand_capacity

func get_hand_size() -> int:
	var all_dice = get_tree().get_nodes_in_group("DiceControl")
	return all_dice.size()

## Creates a DiceControl, its associated DiceData value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		DiceControl.create(DiceData.init(), _hand_container)

func get_player() -> DamageReceiverComponent:
	var player = get_tree().get_first_node_in_group("PlayerControl")
	var dr = Utils.get_first_child_with_tag(player, "DamageReceiverComponent")
	return dr

func get_target() -> DamageReceiverComponent:
	var enemy = get_tree().get_first_node_in_group("EnemyControl")
	var dr = Utils.get_first_child_with_tag(enemy, "DamageReceiverComponent")
	return dr

func end_game():
	get_tree().reload_current_scene()

func _on_gui_target_select(component: DamageReceiverComponent):
	select_target(component)

func _get_random_threat(level: int) -> EnemyData:
	var goblinData = load("res://Assets/EnemyData/GoblinEnemyData.tres")
	var slimeData = load("res://Assets/EnemyData/SlimeEnemyData.tres")
	
	match level:
		var n when n <= 1:
			return slimeData
		var n when n <= 2:
			return goblinData
		_:
			return goblinData
	
	return slimeData

func get_dice_in_reserve():
	var in_group = Utils.get_children_with_tag(_reserve_container, "DiceControl")
	var dcs = []
	for i in in_group:
		if i is DiceControl:
			dcs.append(i)
	return dcs

func _process(delta) -> void:
	if Input.is_action_just_pressed("scroll"):
		var options = get_dice_in_reserve()
		if options.size() == 0:
			Input.set_custom_mouse_cursor(null)
			return
		if options.size() != _dice_count_in_reserve:
			_dice_count_in_reserve = options.size()
			options[0].simulate_pressed()
		else:
			if Input.is_action_just_pressed("scroll_down"):
				_dice_in_reserve_selected_index -= 1
				if _dice_in_reserve_selected_index < 0:
					_dice_in_reserve_selected_index = _dice_count_in_reserve - 1
			elif Input.is_action_just_pressed("scroll_up"):
				_dice_in_reserve_selected_index += 1
				if _dice_in_reserve_selected_index >= _dice_count_in_reserve:
					_dice_in_reserve_selected_index = 0
			options[_dice_in_reserve_selected_index].simulate_pressed()

func _start():
	var enemies: Dictionary = {}
	var current_threat = 0
	for i in max_enemies:
		var random_threat_level = randi_range(1, data.threat_level-current_threat)
		print(random_threat_level)
		var enemy_data = _get_random_threat(random_threat_level)
		
		var enemy = EnemyControl.create(enemy_data, _enemy_container)
		enemies[enemy.get_instance_id()] = enemy_data
		current_threat += enemy_data.threat_weight
		
		if current_threat >= data.threat_level:
			break
	
	for e in enemies.keys():
		var data = enemies[e]
		Ability.register_multiple(e, data.abilities)
	
	_create_player()
	
	match _current_turn:
		Turn.PLAYER:
			call_deferred("_start_player_turn")
		_:
			call_deferred("_start_enemy_turn")

func _start_player_turn():
	if EnemyManager.get_all_alive().size() <= 0:
		Game.start_overworld()
		return
	
	_turns += 1
	_current_turn = Turn.PLAYER
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Player Turn (Turn %s)" % _turns
	
	for i in get_hand_capacity():
		draw_to_hand()
	
	get_tree().get_first_node_in_group("DiceControl").pressed.emit()
	
	Signals.player_start_turn.emit()


func _end_player_turn():
	if _current_turn != Turn.PLAYER:
		return
	
	# Reset Mouse Cursor
	Input.set_custom_mouse_cursor(null)
	
	_current_turn = Turn.PLAYER_EXECUTING
	
	# Get all the ability controls the player has.
	var all_ability_controls: Array[AbilityControl]
	for n in get_tree().get_nodes_in_group("AbilityControl"):
		if n is AbilityControl:
			all_ability_controls.append(n)
	
	# Attempt to invoke all abilities, remove DiceControl from AbilityControl
	for i in all_ability_controls.size():
		# If nothing exists, just stop iterating
		if EnemyManager.get_all_alive().size() <= 0:
			break
		
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
				var sel = TargetSelector.create(control.get_global_rect().get_center(), Game.get_world())
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
	
	Signals.player_end_turn.emit()
	
	_start_enemy_turn()

func _start_enemy_turn():
	_current_turn = Turn.ENEMY
	
	var turn_label = get_tree().get_first_node_in_group("Turn Label")
	if turn_label:
		turn_label.text = "Enemy Turn"
	
	Signals.enemy_start_turn.emit()
	
	_end_enemy_turn()

func _end_enemy_turn():
	if _current_turn != Turn.ENEMY:
		return
	
	_current_turn = Turn.ENEMY_EXECUTING
	
	var enemies = EnemyManager.get_all_alive()
	var targets: Array[DamageReceiverComponent] = [get_player()]
	
	for enemy in enemies:
		var abilities = Ability.get_abilities(enemy.get_instance_id())
		if !abilities: 
			continue
		
		var index = Ability.get_invoked_ability_index(enemy.get_instance_id()) + 1
		
		print ("INFO %s is alive!  They have %s abilities!  They rolled %s ability" % [enemy.get_damage_receiver().display_name, abilities.size(), index])
		Ability.invoke(enemy.get_instance_id(), [DiceData.init(99)], enemy.get_damage_receiver(), targets, index)
	
	Signals.enemy_end_turn.emit()
	
	await get_tree().create_timer(1).timeout
	
	_start_player_turn()

func _create_player():
	var playerStats = load("res://Assets/DamageReceiverData/Player/PlayerStats.tres")
	var playerAbilities : Array[AbilityData] = [Ability.stab, Ability.wrecklessSwing, Ability.raiseShield] #, Ability.wtf
	
	# Create player
	var player = PlayerControl.create(playerStats, _field_container)
	
	# Create player abilities and UI
	for ability in playerAbilities:
		AbilityControl.create(ability, _ability_container)
		Ability.register(player.get_instance_id(), ability)
	
	_player = player
