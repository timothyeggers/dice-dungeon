class_name DamageData extends Resource

@export var amount := 2
@export var ignore_armor := false
@export var fire_damage := 0
@export var lightning_damage := 0
@export var dark_damage := 0
@export var accuracy: float = 1.0
@export var max_targets: int = 1

func get_message() -> String:
	var message = ""
	
	if ignore_armor:
		message += " Ignores armor. "
	if accuracy < 1:
		message += " %s% change to hit. " % str(accuracy * 100)
	if amount > 0:
		message += "Deals %s physical damage. " % amount
	if fire_damage > 0:
		message += "Deals %s fire damage. " % fire_damage
	if lightning_damage > 0:
		message += "Deals %s lightning damage. " % lightning_damage
	if dark_damage > 0:
		message += "Deals %s lightning damage. " % dark_damage
	if max_targets > 1:
		message += " Hits up to %s targets. " % max_targets
	
	return message
