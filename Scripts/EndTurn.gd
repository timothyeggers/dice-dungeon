extends Button

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	print("Move to hand clicked.")
	Game.end_turn()
