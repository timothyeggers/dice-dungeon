class_name ToolTipControl extends Control

@export var _label: Label
@export var toolTip: ToolTip

static func create_with(toolTip: ToolTip) -> ToolTipControl:
	var scene = load("res://Assets/ToolTipControl.tscn")
	var control: ToolTipControl = scene.instantiate()
	control.toolTip = toolTip
	
	return control

static func create(message: String) -> ToolTipControl:
	var scene = load("res://Assets/ToolTipControl.tscn")
	var control: ToolTipControl = scene.instantiate()
	var toolTip = ToolTip.new()
	toolTip.message = message
	control.toolTip = toolTip
	
	return control

func _ready():
	if (toolTip):
		_label.text = toolTip.message
