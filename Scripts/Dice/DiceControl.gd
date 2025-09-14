class_name DiceControl extends TextureButton

const scene = preload("res://Assets/Dice/DiceControl.tscn")

@export var dice: Dice

static func create(dice: Dice) -> DiceControl:
	var control: DiceControl = scene.instantiate()
	control.dice = dice
	return control

func _ready():
	add_to_group("dice")
	
	if (!dice):
		dice = Dice.new()
		dice.value = randi_range(1,6)
	
	# Setup the UI
	rotation_degrees = 90 * randi_range(0, 4)
	var resource = "res://Assets/Dice/dice_number_%s.png"
	var numberControl = TextureRect.new()
	numberControl.texture = load(resource  % dice.value)
	add_child(numberControl)
	
	# Signals
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_pressed)

## Returns the Dice value, not reference.
func get_dice() -> Dice:
	return dice.duplicate()

func _on_pressed():
	print(dice.value)
	Game.select_dice(self)

func _on_hover():
	print("Hovered over %s" % dice.value)
	pass
	#position.x = anchor_right + 15

func _on_unhover():
	pass
	#position.x = anchor_left
