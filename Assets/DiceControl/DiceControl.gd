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
	texture_normal = _create_dice_texture(CursorContext.dice_cursor_background.resource_path)
	texture_focused = _create_dice_texture(CursorContext.dice_cursor_background_focused.resource_path)
	
	# Signals
	pressed.connect(_on_pressed)

## Returns the DiceData value, not reference.
func get_dice() -> DiceData:
	return data.duplicate()

## Builds dice texture using a dice face and dice background
func _create_dice_texture(dice_background : NodePath) -> Texture:
	# Load textures from the file system
	var texture1 = load(dice_background)
	var texture2 = load(CursorContext.dice_cursor_foreground % data.value)
	
	return _blend_texture(texture1, texture2)

func _blend_texture(texture1, texture2, texture1_offset = Vector2i.ZERO, texture2_offset = Vector2i.ZERO, scale := Vector2i.ONE) -> Texture:
	# Convert textures to Image resources
	var image1 = texture1.get_image()
	var image2 = texture2.get_image()
	
	#var size = Vector2(image1.get_width() + image2.get_width(), image1.get_height() + image2.get_height())
	#var new_image = Image.create(size.x, size.y, false, image1.get_format())
	var new_width = image1.get_width()
	var new_height = image1.get_height()
	if scale != Vector2i.ONE:
		new_width *= scale.x
		new_height *= scale.y
	var new_image = Image.create(new_width, new_height, false, image1.get_format())
	
	var rect = Rect2i(Vector2i.ZERO, image1.get_size())
	new_image.blend_rect(image1, rect, texture1_offset) # Copy base image
	new_image.blend_rect(image2, rect, texture2_offset) # Blend overlay image
	
	return ImageTexture.create_from_image(new_image)

func get_dice_cursor(width := 48, height := 48) -> Texture2D:
	var image: Image = texture_normal.get_image()
	image.resize(width, height, Image.INTERPOLATE_NEAREST)
	
	var resized_texture = ImageTexture.create_from_image(image)
	
	var cursor_blend = _blend_texture(resized_texture, CursorContext.top_left_cursor, Vector2i(16, 16), Vector2i.ZERO, Vector2i(3,3))
	
	return cursor_blend

func get_dice_focused_cursor() -> Texture2D:
	return texture_focused

func deselect():
	release_focus()
	Signals.dice_deselected.emit(self)

## Useful for selecting a dice through code and not an actual mouse click.
func simulate_pressed():
	pressed.emit()

func _on_pressed():
	grab_focus()
	Signals.dice_selected.emit(self)
