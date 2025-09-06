class_name Dice extends Resource

@export var value: int = 0

static func create(value := randi_range(1, 6)) -> Dice:
	var dice = Dice.new()
	dice.value = value
	return dice
