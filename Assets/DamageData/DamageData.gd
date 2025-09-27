class_name DamageData extends Resource

@export var amount := 2
@export var ignore_armor := false
@export var decay := 0
@export var fire_damage := 0
@export var lightning_damage := 0
@export var dark_damage := 0
@export var accuracy: float = 1.0
@export var max_targets = 1

func get_message() -> String:
	var message = ""
	
	if accuracy < 1:
		message += "%s%% change to hit. " % int(accuracy * 100)
	if amount > 0:
		message += "Deals %s physical damage. " % amount
	if ignore_armor:
		message += "Ignores armor. "
	if decay > 0:
		message += "Deals %s decay. " % decay
	message += "\n"
	if fire_damage > 0:
		message += "Deals %s fire damage. " % fire_damage
	if lightning_damage > 0:
		message += "Deals %s lightning damage. " % lightning_damage
	if dark_damage > 0:
		message += "Deals %s lightning damage. " % dark_damage
	message += "\n"
	if max_targets > 1:
		message += "Up to %s targets. " % max_targets
	
	return message
