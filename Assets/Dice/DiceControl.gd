class_name DiceControl extends TextureButton

@export var data: DiceParameter

static func create(dice: DiceParameter) -> DiceControl:
	var scene = load("res://Assets/Dice/DiceControl.tscn")
	var control: DiceControl = scene.instantiate()
	control.data = dice
	return control

func _ready():
	add_to_group("DiceControl")
	
	if (!data):
		data = DiceParameter.new()
		data.value = randi_range(1,6)
	
	# Setup the UI
	rotation_degrees = 90 * randi_range(0, 4)
	var resource = "res://Assets/Dice/Resources/dice_number_%s.png"
	var numberControl = TextureRect.new()
	numberControl.texture = load(resource  % data.value)
	add_child(numberControl)
	
	# Signals
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_pressed)

## Returns the DiceParameter value, not reference.
func get_dice() -> DiceParameter:
	return data.duplicate()

func _on_pressed():
	Game.select_dice(self)

func _on_hover():
	pass

func _on_unhover():
	pass
