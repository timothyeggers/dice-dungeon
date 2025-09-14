extends Button

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	print("Reserved clicked.")
	Game.move_to_reserve()
