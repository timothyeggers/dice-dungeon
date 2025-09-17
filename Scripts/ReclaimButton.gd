extends Button

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	Game.move_all_to_hand()
