extends Node

signal player_end_turn
signal enemy_end_turn

var _selected_dice: DiceControl
var _hand_capacity := 2

var murkyStab = load("res://Assets/AbilityData/Attacks/MurkyStab.tres")
var stab = load("res://Assets/AbilityData/Attacks/Stab.tres")
var wrecklessSwing = load("res://Assets/AbilityData/Attacks/WrecklessSwing.tres")

# Defense Abilities
var reinforce = load("res://Assets/AbilityData/Defensives/Reinforce.tres")
var steadfast = load("res://Assets/AbilityData/Defensives/Steadfast.tres")

# Goblin Information
var goblinStats = load("res://Assets/DamageReceiverData/NPCs/GoblinStats.tres")
var goblinPortrait = load("res://Assets/Enemy/Resources/Goblin.png")

# game start
func _ready():
	var endTurnButton = get_tree().get_first_node_in_group("End Turn Button") as Button
	endTurnButton.pressed.connect(end_turn)
	enemy_end_turn.connect(start_turn)
	
	start_game()

func create_goblin():
	var goblinAbilities : Array[AbilityData] = [murkyStab, reinforce, murkyStab, stab]
	
	# Add npcs
	var npcs = get_tree().get_first_node_in_group("NPC Container")
	if (npcs):
		var abilityComponents : Array[AbilityComponent] = []
		for ability in goblinAbilities:
			var component = AbilityComponent.create(ability)
			npcs.add_child(component)
			abilityComponents.append(component)
		var enemy = EnemyControl.create(goblinStats, abilityComponents, goblinPortrait)
		enemy.death.connect(enemy.queue_free)
		npcs.add_child(enemy)

func start_game():
	# Attack Abilities
	
	create_goblin()
	create_goblin()
	create_goblin()
	
	var playerStats = load("res://Assets/DamageReceiverData/Player/PlayerStats.tres")
	var playerAbilities : Array[AbilityData] = [wrecklessSwing, steadfast, stab]
	
	# Add player abilities
	var field = get_tree().get_first_node_in_group("Field Container")
	var abilityContainer = get_tree().get_first_node_in_group("Ability Container")
	if (field):
		var player = PlayerControl.create(playerStats, null)
		player.death.connect(end_game)
		field.add_child(player)
		for ability in playerAbilities:
			abilityContainer.add_child(AbilityControl.create(ability))
	
	for i in get_hand_capacity():
		draw_to_hand()

func end_game():
	get_tree().reload_current_scene()

func start_turn():
	await get_tree().create_timer(1).timeout
	
	var dice = get_tree().get_nodes_in_group("DiceControl")
	for d in dice: 
		d.remove_from_group("DiceControl")
		d.queue_free()
	
	
	for i in get_hand_capacity():
		draw_to_hand()

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
		print("Drawed one")
		# Randomize this eventually?
		var control = DiceControl.create(DiceData.create())
		
		var hand = get_tree().get_first_node_in_group("Hand Container")
		if (hand):
			hand.add_child(control)

func get_player() -> DamageReceiverComponent:
	var player = get_tree().get_first_node_in_group("PlayerControl")
	var dr = Utils.get_first_child_with_tag(player, "DamageReceiverComponent")
	return dr

func get_target() -> DamageReceiverComponent:
	var enemy = get_tree().get_first_node_in_group("EnemyControl")
	var dr = Utils.get_first_child_with_tag(enemy, "DamageReceiverComponent")
	return dr

func end_turn():
	player_end_turn.emit()
