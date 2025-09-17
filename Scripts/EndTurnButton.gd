extends Button

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	Game.end_turn_pressed()
