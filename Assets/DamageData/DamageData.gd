class_name DamageData extends Resource

@export var amount := 2
@export var ignore_armor := false
@export var decay := 0
@export var fire_damage := 0
@export var lightning_damage := 0
@export var dark_damage := 0
@export var accuracy: float = 1.0
@export var max_targets = 1

static func init(amount: int, decay: int = 0, fire_damage: int = 0, lightning_damage: int = 0, dark_damage: int = 0) -> DamageData:
	var dmg = DamageData.new()
	dmg.amount = amount
	dmg.decay = decay
	dmg.fire_damage = fire_damage
	dmg.lightning_damage = lightning_damage
	dmg.dark_damage = dark_damage
	return dmg

## Returns all the (non debuffing) damage(s) added
func get_total_raw() -> int:
	return amount + fire_damage + lightning_damage + dark_damage

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
