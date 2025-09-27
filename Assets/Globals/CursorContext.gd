extends Node

const top_left_cursor = preload("res://Assets/Icons/Cursors/top_left_arrow.png")
const target_cursor = preload("res://Assets/Icons/Cursors/target.png")
const dice_cursor_background = preload("res://Assets/DiceControl/Resources/dice_background.png")
const dice_cursor_background_focused = preload("res://Assets/DiceControl/Resources/dice_background_focus.png")
const dice_cursor_foreground = "res://Assets/DiceControl/Resources/dice_number_%s.png"

func set_context_icon(texture: Texture2D, center_of_texture := true):
	var center = Vector2.ZERO
	if center_of_texture && texture:
		center = texture.get_size() / 2
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, center)
