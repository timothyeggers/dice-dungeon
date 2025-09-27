class_name PathData extends Resource

static func create_default() -> PathData:
	return load("res://Assets/Overworld/PathData/DefaultPathData.tres")

@export var title: String
@export var threat_level: int
@export var rewards: Array
@export var background: Texture
@export var modifiers: Array
