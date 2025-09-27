class_name PathOptionControl extends Control

var empty_reward = preload("res://Assets/Icons/crossed_bones.png")

@export var _title: Label
@export var _activate: Button
@export var _threat_level: Label
@export var _mods: RichTextLabel
@export var _rewards_container: Container

var data := PathData.create_default()

static func create(data: PathData, attach_to: Node2D) -> PathOptionControl:
	var node = load("res://Assets/Overworld/PathOptionControl/PathOptionControl.tscn").instantiate()
	node.data = data
	
	attach_to.add_child(node)
	
	return node

func _ready():
	assert(_activate, "PathOption needs an activate button control.")
	assert(data, "PathOption needs data: PathData!")
	
	_activate.pressed.connect(_on_select)
	
	create_ui(data)

func _on_select():
	Game.start_battle(data)

func create_ui(from: PathData):
	if _title:
		_title.text = from.title
	if _threat_level:
		_threat_level.text = "Threat Level: %s" % from.threat_level
	if _mods:
		_mods.clear()
		if from.modifiers.size() == 0:
			_mods.text = "- None"
		for mod in from.modifiers:
			if mod is BuffData:
				_mods.append_text("- %s" % str(mod.get_message()))
			else:
				_mods.append_text("- %s" % str(mod))
			_mods.newline()
	if _rewards_container:
		for child in _rewards_container.get_children():
			child.queue_free()
		_create_reward_icon(empty_reward)
		for reward in from.rewards:
			_create_reward_icon(reward.texture)

func _create_reward_icon(texture: Texture):
	if !_rewards_container:
		return
	
	var rect = TextureRect.new()
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP
	
	_rewards_container.add_child(rect)
