class_name DiceControl extends TextureButton

@export var data: DiceData

static func create(dice: DiceData, attach_to: Node) -> DiceControl:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/DiceControl/DiceControl.tscn")
	var control: DiceControl = scene.instantiate()
	control.data = dice
	
	attach_to.add_child(control)
	
	return control

func _ready():
	add_to_group("DiceControl")
	
	if (!data):
		data = DiceData.new()
		data.value = randi_range(1,6)
	
	# Setup the UI
	rotation_degrees = 90 * randi_range(0, 4)
	var resource = "res://Assets/DiceControl/Resources/dice_number_%s.png"
	var numberControl = TextureRect.new()
	numberControl.texture = load(resource  % data.value)
	add_child(numberControl)
	
	# Signals
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_pressed)

## Returns the DiceData value, not reference.
func get_dice() -> DiceData:
	return data.duplicate()

func _on_pressed():
	Game.select_dice(self)

func _on_hover():
	pass

func _on_unhover():
	pass
