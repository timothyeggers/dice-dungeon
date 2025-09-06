extends Control

func _ready() -> void:
	Signals.dice_registered.connect(_update)

func _update():
	pass

func _on_draw_pressed() -> void:
	Game.draw_to_hand()
