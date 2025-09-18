extends Node

signal end_turn

var _selected_dice: DiceControl
var _hand_capacity := 4

# game start
func _ready():
	start_game()
	
	var endTurnButton = get_tree().get_first_node_in_group("End Turn Button") as Button
	endTurnButton.pressed.connect(turn_end)

func start_game():
	# Attack Abilities
	var murkyStab = load("res://Assets/AbilityParameter/Resources/Attacks/MurkyStab.tres")
	var stab = load("res://Assets/AbilityParameter/Resources/Attacks/Stab.tres")
	var wrecklessSwing = load("res://Assets/AbilityParameter/Resources/Attacks/WrecklessSwing.tres")
	
	# Defense Abilities
	var reinforce = load("res://Assets/AbilityParameter/Resources/Defensives/Reinforce.tres")
	var steadfast = load("res://Assets/AbilityParameter/Resources/Defensives/Steadfast.tres")
	
	# Goblin Information
	var goblinStats = load("res://Assets/Enemy/Resources/GoblinStats.tres")
	var goblinPortrait = load("res://Assets/Enemy/Resources/Goblin.png")
	var goblinAbilities : Array[AbilityParameter] = [reinforce, murkyStab, stab]
	
	# Add npcs
	var npcs = get_tree().get_first_node_in_group("NPC Container")
	if (npcs):
		var abilityComponents : Array[AbilityComponent] = []
		for ability in goblinAbilities:
			var component = AbilityComponent.create(ability)
			npcs.add_child(component)
			abilityComponents.append(component)
		npcs.add_child(EnemyControl.create(goblinStats, abilityComponents, goblinPortrait))
	
	var playerStats = load("res://Assets/Player/Resources/PlayerStats.tres")
	var playerAbilities : Array[AbilityParameter] = [wrecklessSwing, steadfast, stab]
	
	# Add player abilities
	var field = get_tree().get_first_node_in_group("Field Container")
	var abilityContainer = get_tree().get_first_node_in_group("Ability Container")
	if (field):
		field.add_child(PlayerControl.create(playerStats, null))
		for ability in playerAbilities:
			abilityContainer.add_child(AbilityControl.create(ability))
	
	
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

## Creates a DiceControl, its associated DiceParameter value, and adds the DiceControl to the Hand UI.
func draw_to_hand():
	if get_hand_size() < get_hand_capacity():
		# Randomize this eventually?
		var control = DiceControl.create(DiceParameter.create())
		
		var hand = get_tree().get_first_node_in_group("Hand Container")
		if (hand):
			hand.add_child(control)

func get_player() -> DamageReceiver:
	var enemy = get_tree().get_first_node_in_group("PlayerControl")
	var dr = Utils.get_first_child_with_tag(enemy, "DamageReceiver")
	return dr

func get_target() -> DamageReceiver:
	var enemy = get_tree().get_first_node_in_group("EnemyControl")
	var dr = Utils.get_first_child_with_tag(enemy, "DamageReceiver")
	return dr

func turn_end():
	end_turn.emit()
