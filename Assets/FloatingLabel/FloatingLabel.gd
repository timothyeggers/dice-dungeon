class_name FloatingLabel extends Label

const time_alive_is_new = 0.05

var owner_id: int = 0
var keyname := ""
var amount: float = 0

@export var _animator: AnimationPlayer
@export var _offset_x: float = 0
@export var _offset_y: float = 0
var _time_alive = 0


static func create(owner_id: int, keyname: String, amount: float, g_position: Vector2, attach_to: Node, color := Color.BLACK) -> FloatingLabel:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/FloatingLabel/FloatingLabel.tscn")
	var node = scene.instantiate()
	node.owner_id = owner_id
	node.keyname = keyname
	node.amount = amount
	node.add_theme_color_override("font_shadow_color", color)
	node.text = get_message(keyname, amount)
	node.global_position = g_position
	
	attach_to.add_child(node)
	
	return node

static func get_message(keyname, amount):
	if amount == 0:
		return keyname
	return "%s %s" % [amount, keyname]

func _enter_tree():
	UI.add_floating_label(owner_id, keyname, amount)
	
func _exit_tree():
	UI.remove_floating_label(owner_id)

func get_time_alive() -> float:
	return _time_alive

func reset():
	_animator.seek(0)
	_animator.play("jump_fading")
	text = get_message(keyname, amount)

func _ready():
	_animator.seek(0)
	_animator.play("jump_fading")
	
	add_to_group(str(owner_id))
	add_to_group(keyname)
	add_to_group(UI.get_unique_key(owner_id, keyname))

func _process(delta: float) -> void:
	global_position.y += _offset_y * delta
	global_position.x += _offset_x * delta
	_time_alive += delta
