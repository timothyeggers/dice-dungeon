class_name DiceData extends Resource

@export var value: int = 0

static func create(value := randi_range(1, 6)) -> DiceData:
	var dice = DiceData.new()
	dice.value = value
	return dice
