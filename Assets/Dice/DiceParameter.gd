class_name DiceParameter extends Resource

@export var value: int = 0

static func create(value := randi_range(1, 6)) -> DiceParameter:
	var dice = DiceParameter.new()
	dice.value = value
	return dice
