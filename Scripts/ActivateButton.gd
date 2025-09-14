extends Button

@export var control: AbilityControl

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	print(control.ability.name)
	print("Move to ability")
	Game.move_to_ability(control)
