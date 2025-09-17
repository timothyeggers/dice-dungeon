extends Node

signal end_turn

var _in_hand: Array[DiceParameter] = []
var _hand_capacity: int

# Move to somewhere else
var health = 10:
	set(value):
		health = max(0, value)
		if (health_label): health_label.text = "Health: %s" % health
var shield = 0:
	set(value):
		shield = max(0, value)
		if (shield_label): shield_label.text = "Shield: %s" % shield
var decay = 0:
	set(value):
		decay = value
		if (decay_label): decay_label.text = "Decay Shield: %s" % decay

var reserve_capacity = 2

# Load pre-requisite UI into Game memory.
@onready var hand = get_tree().get_first_node_in_group("container_hand")
@onready var npcs = get_tree().get_first_node_in_group("container_npcs")
@onready var abilities = get_tree().get_first_node_in_group("container_abilities")
@onready var reserve = get_tree().get_first_node_in_group("container_reserve")
@onready var health_label = get_tree().get_first_node_in_group("label_health") as Label
@onready var shield_label = get_tree().get_first_node_in_group("label_shield") as Label
@onready var decay_label = get_tree().get_first_node_in_group("label_decay") as Label
@onready var debug_text = get_tree().get_first_node_in_group("text_debug") as TextEdit

var _invoker: AbilityInvoker

var enemies_killed = 0

var _selected_dice: DiceControl

func selected_dice() -> DiceControl:
	return _selected_dice

func select_dice(diceControl: DiceControl):
	_selected_dice = diceControl

func get_all_dice() -> Array:
	var dice = get_tree().get_nodes_in_group("control_dice")
	return dice

#region Moving DiceParameter
func move_to_hand():
	if (selected_dice()):
		if (hand):
			selected_dice().get_parent().remove_child(selected_dice())
			hand.add_child(selected_dice())

func move_all_to_hand():
	for dice in get_all_dice():
		if (hand):
			dice.get_parent().remove_child(dice)
			hand.add_child(dice)
			select_dice(null)


func move_to_reserve():
	if (selected_dice()):
		if (reserve):
			if Utils.get_children_with_tag(reserve, "control_dice").size() < reserve_capacity:
				selected_dice().get_parent().remove_child(selected_dice())
				reserve.add_child(selected_dice())
				var in_reserve : Array = get_all_dice().filter(in_reserve)
				var total = 0
				for r in in_reserve:
					total += r.dice.value
				
				shield_label.text = "Shield: %s (+%s)" % [shield, ceil(total / 2.0)]
				
				select_dice(null)
			else:
				print_terminal("You've exceeded the dice reserve capacity.")
#endregion

func in_reserve(dice: DiceControl):
	if dice.get_parent() == reserve:
		return true
	return false

# game start
func _ready():
	_hand_capacity = 3
	health = 10
	
	start_game()

func start_game():
	# Attack Abilities
	var murkyStab = load("res://Assets/Ability/Resources/Attacks/MurkyStab.tres")
	var stab = load("res://Assets/Ability/Resources/Attacks/Stab.tres")
	var wrecklessSwing = load("res://Assets/Ability/Resources/Attacks/WrecklessSwing.tres")
	
	# Defense Abilities
	var reinforce = load("res://Assets/Ability/Resources/Defensives/Reinforce.tres")
	var steadfast = load("res://Assets/Ability/Resources/Defensives/Steadfast.tres")
	
	# Goblin Information
	var goblinStats = load("res://Assets/Enemy/Resources/GoblinStats.tres")
	var goblinPortrait = load("res://Assets/Enemy/Resources/Goblin.png")
	var goblinAbilities : Array[AbilityParameter] = [reinforce, murkyStab, stab]
	
	# Add npcs
	if (npcs):
		npcs.add_child(EnemyControl.create(goblinStats, goblinAbilities, goblinPortrait))
	
	# Add player abilities
	abilities.add_child(AbilityControl.create(wrecklessSwing))
	abilities.add_child(AbilityControl.create(steadfast))
	abilities.add_child(AbilityControl.create(stab))
	
	_invoker = load("res://Assets/Ability/Component/AbilityInvoker.tscn").instantiate()
	
	
	start_turn()

func print_terminal(text: String):
	if (debug_text):
		debug_text.text+= str(text) + "\n"
		debug_text.scroll_vertical = debug_text.get_line_count()

func start_turn():
	# Draw dice to hand
	for i in _hand_capacity:
		draw_to_hand()
	select_dice(null)
	
	

func end_turn_pressed():
	end_turn.emit()
	return
	#
	# ADD overcharge, statically adds 1 damage per extra dice when ability cost is already exceeded.
	#
	#
	#
	var all_dice = get_tree().get_nodes_in_group("control_dice")
	
	var abilities_in_check: Dictionary # abilityControl key to diceControls
	
	var target = get_tree().get_first_node_in_group("DamageReceiver")
	
	for dice in all_dice:
		var parent = dice.get_parent()
		var ability = parent.get_parent().get_parent().get_parent()
		if parent == reserve:
			var amount: int = ceili(dice.dice.value / 2.0)
			shield += amount
			print_terminal("Granting shield: %s, dice of %s value consumed." % [amount, dice.dice.value])
		if ability is AbilityControl:
			print("Found %s in ability %s" % [dice.data.value, ability._invoker.data[0].name])
			if !abilities_in_check.has(ability):
				abilities_in_check[ability] = [dice]
			else:
				abilities_in_check[ability].append(dice)
	
	for ability in abilities_in_check.keys():
		var total = 0
		for dice in abilities_in_check[ability]:
			total += dice.data.value
		# Currently adds 1 extra damage per extra dice.
		# add another ability that adds a second swing with flat damage if matched. two costs. two procs.
		if total >= ability._invoker.data[0].cost:
			ability._invoker.invoke(target)
	
	# Apply decay
	shield -= decay
	
	if (decay > 0):
		decay -= 1
	
	for dice in all_dice:
		var parent = dice.get_parent()
		parent.remove_child(dice)
	
	enemy_turn()

func enemy_turn():
	return
	print_terminal("Enemy turn start.")
	var all_enemies = get_tree().get_nodes_in_group("control_enemy") as Array[EnemyControl]
	var dead_count = 0
	for enemy in all_enemies:
		if (enemy.is_dead):
			print_terminal("Killed enemy %s!" % enemy.stats.name)
			dead_count += 1
			continue
		if enemy.health <= 0:
			continue
		enemy.perform()
		
		if health <= 0:
			print_terminal("You died by %s, and have %s health..." % [enemy.stats.name, health])
			print_terminal("You killed %s goblins!" % enemies_killed)
			get_tree().paused = true
			#get_tree().reload_current_scene()
	
	if dead_count == all_enemies.size():
		print("Starting new")
		start_game()
	
	start_turn()

enum ActionType {
	ATTACK
}

func enemy_action(enemy: EnemyControl, action_type: ActionType, params: DamageParameter):
	if action_type == ActionType.ATTACK:
		take_damage(params)


func take_damage(params: DamageParameter):
	var delta = shield - params.amount
	decay += params.decay
	shield -= params.amount
	if (delta <= 0):
		health += delta
	print_terminal("Dealed %s damage to player." % params.amount)
	print_terminal("Dealed %s damage to player health." % abs(delta))
	print_terminal("Applied %s decay to player." % params.decay)

## Randomly creates a DiceControl and associated DiceParameter.
func create_dice() -> DiceControl:
	var dice = DiceParameter.create()
	var control = DiceControl.create(dice)
	
	return control

## Creates a DiceControl, its associated DiceParameter value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		# Randomize this eventually?
		var control = create_dice()
		
		_in_hand.append(control.data)
		
		# Add DiceControl to Hand UI.
		if (hand):
			hand.add_child(control)

func get_hand_capacity() -> int:
	return _hand_capacity

func get_hand_size() -> int:
	var all_dice = get_tree().get_nodes_in_group("control_dice")
	return all_dice.size()
