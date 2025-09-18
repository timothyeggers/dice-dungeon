class_name BuffData extends Resource

@export var shield := 2
@export var regen := 1
@export var heal := 0
@export var decay := 0

func get_message() -> String:
	var message = ""
	
	if shield != 0:
		message += "Grants %s shield. " % shield
	if regen != 0:
		message += "Grants %s regen." % regen
	if heal != 0:
		message += "Grants %s health." % heal
	if decay > 0:
		message += "Deals %s decay damage. " % decay
	
	return message
