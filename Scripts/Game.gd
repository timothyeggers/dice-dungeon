extends Node

var _in_hand: Array[Dice] = []
var _hand_capacity: int

var health = 10:
	set(value):
		health = value
		health_ui.text = "Health: %s" % value
var shield = 0:
	set(value):
		shield = value
		shield_ui.text = "Shield: %s" % value

@onready var hand = get_tree().get_first_node_in_group("ui_hand")
@onready var npcs = get_tree().get_first_node_in_group("ui_npcs")
@onready var abilities = get_tree().get_first_node_in_group("ui_abilities")
@onready var reserve = get_tree().get_first_node_in_group("ui_reserve")
@onready var health_ui = get_tree().get_first_node_in_group("ui_health") as Label
@onready var shield_ui = get_tree().get_first_node_in_group("ui_shield") as Label

var enemies_killed = 0

var _selected_dice: DiceControl

func selected_dice() -> DiceControl:
	return _selected_dice

func select_dice(diceControl: DiceControl):
	_selected_dice = diceControl

func move_to_hand():
	if (selected_dice()):
		if (hand):
			selected_dice().get_parent().remove_child(selected_dice())
			hand.add_child(selected_dice())
			select_dice(null)

func move_to_ability(control: AbilityControl):
	if (selected_dice()):
		#if (selected_dice().dice.value >= control.ability.cost):
		selected_dice().get_parent().remove_child(selected_dice())
		var cost_control = control.find_child("Cost")
		#cost_control.visible = false
		control.cost = selected_dice()
		cost_control.add_child(selected_dice())
		
		select_dice(null)

func move_to_reserve():
	if (selected_dice()):
		if (reserve):
			selected_dice().get_parent().remove_child(selected_dice())
			reserve.add_child(selected_dice())
			select_dice(null)

# game start
func _ready():
	_hand_capacity = 3
	health = 10
	
	start_game()

func start_game():
	
	var goblin = EnemyStats.new()
	goblin.name = "Goblin"
	goblin.health = 5
	goblin.portrait = load("res://Assets/Pawn/Goblin.png")
	goblin.max_range = 3
	if (npcs):
		npcs.add_child(EnemyControl.create(goblin))
	
	var taunt = Ability.new()
	taunt.name = "Taunt"
	taunt.cost = 3
	taunt.damage = 0
	taunt.flavor_text = "Arrrrgg!!"
	
	var attack = Ability.new()
	attack.name = "Swing"
	attack.cost = 2
	attack.damage = 2
	attack.flavor_text = "Kachink!"
	
	for child in abilities.get_children():
		abilities.remove_child(child)
	
	if (abilities):
		abilities.add_child(AbilityControl.create(taunt))
		abilities.add_child(AbilityControl.create(attack))
	
	
	shield = 0
	print("Started a new game")
	start_turn()

func start_turn():
	for i in _hand_capacity:
		draw_to_hand()
	select_dice(null)

	#shield = 0

func end_turn():
	#
	# ADD overcharge, statically adds 1 damage per extra dice when ability cost is already exceeded.
	#
	#
	#
	var all_dice = get_tree().get_nodes_in_group("ui_dice")
	
	var abilities_in_check: Dictionary # abilityControl key to diceControls
	
	for dice in all_dice:
		var parent = dice.get_parent()
		var ability = parent.get_parent().get_parent().get_parent()
		if parent == reserve:
			print("Found %s in reserve, worth $s" % [dice.name, dice.dice.value])
			shield += dice.dice.value
		if ability is AbilityControl:
			print("Found %s in ability %s" % [dice.dice.value, ability.ability.name])
			if !abilities_in_check.has(ability):
				abilities_in_check[ability] = [dice]
			else:
				abilities_in_check[ability].append(dice)
	
	for ability in abilities_in_check.keys():
		print(ability)
		var total = 0
		for dice in abilities_in_check[ability]:
			print(dice.dice.value)
			total += dice.dice.value
			if total >= ability.ability.cost:
				print("Dice value cost exceeded ability cost. Activating %s..." % ability.ability.name)
				for enemy in get_tree().get_nodes_in_group("ui_enemy"):
					(enemy as EnemyControl).take_damage(ability.ability.damage)
	
	for dice in all_dice:
		var parent = dice.get_parent()
		parent.remove_child(dice)
	
	enemy_turn()

func enemy_turn():
	print("Enemy turn start.")
	var all_enemies = get_tree().get_nodes_in_group("ui_enemy") as Array[EnemyControl]
	for enemy in all_enemies:
		if (enemy.is_dead):
			start_game()
			break
			#continue
		if enemy.stats.current_health <= 0:
			print("Killed enemy! %s" % enemy.stats.name)
			continue
		print("Enemy is doing thing")
		enemy.perform()
		
		if health <= 0:
			print("You died by %s, and have %s health..." % [enemy.stats.name, health])
			print("You killed %s goblins!" % enemies_killed)
			get_tree().reload_current_scene()
	
	start_turn()

enum ActionType {
	ATTACK
}

func enemy_action(enemy: EnemyControl, action_type: ActionType, value: int):
	if action_type == ActionType.ATTACK:
		var diff = shield - value
		shield -= value
		if (diff <= 0):
			health += diff
			shield = 0
		print("Dealed %s damage to player." % value)

## Randomly creates a DiceControl and associated Dice.
func create_dice() -> DiceControl:
	var dice = Dice.create()
	var control = DiceControl.create(dice)
	
	return control

## Creates a DiceControl, its associated Dice value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		# Randomize this eventually?
		var control = create_dice()
		
		Signals.dice_registered.emit(control.dice)
		_in_hand.append(control.dice)
		
		# Add DiceControl to Hand UI.
		if (hand):
			hand.add_child(control)

func get_hand_capacity() -> int:
	return _hand_capacity

func get_hand_size() -> int:
	var all_dice = get_tree().get_nodes_in_group("ui_dice")
	return all_dice.size()
