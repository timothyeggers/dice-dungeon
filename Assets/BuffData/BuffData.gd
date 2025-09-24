## BuffData always targets self.
class_name BuffData extends Resource

@export var shield := 2
@export var regen := 1
@export var heal := 0

static func init(shield: int, regen: int, heal: int) -> BuffData:
	var buff = BuffData.new()
	buff.shield = shield
	buff.regen = regen
	buff.heal = heal
	return buff

func get_message() -> String:
	var message = ""
	
	if shield != 0:
		message += "Grants %s shield. " % shield
	if regen != 0:
		message += "Grants %s regen." % regen
	if heal != 0:
		message += "Grants %s health." % heal
	
	return message
