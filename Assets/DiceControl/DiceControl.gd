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
	texture_normal = _create_dice_texture("res://Assets/DiceControl/Resources/dice_background.png")
	texture_focused = _create_dice_texture("res://Assets/DiceControl/Resources/dice_background_focus.png")
	
	# Signals
	pressed.connect(_on_pressed)

## Returns the DiceData value, not reference.
func get_dice() -> DiceData:
	return data.duplicate()

## Builds dice texture using a dice face and dice background
func _create_dice_texture(dice_background : NodePath) -> Texture:
	# Load textures from the file system
	var texture1 = load(dice_background)
	var texture2 = load("res://Assets/DiceControl/Resources/dice_number_%s.png" % data.value)

	# Convert textures to Image resources
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	var new_image = Image.create(image1.get_width(), image1.get_height(), false, image1.get_format())
	
	var rect = Rect2i(Vector2i.ZERO, image1.get_size())
	new_image.blend_rect(image1, rect, Vector2i.ZERO) # Copy base image
	new_image.blend_rect(image2, rect, Vector2i.ZERO) # Blend overlay image
	
	var final_texture = ImageTexture.create_from_image(new_image)
	return final_texture

func deselect():
	release_focus()
	Signals.dice_deselected.emit(self)

## Useful for selecting a dice through code and not an actual mouse click.
func simulate_pressed():
	pressed.emit()

func _on_pressed():
	grab_focus()
	Signals.dice_selected.emit(self)
