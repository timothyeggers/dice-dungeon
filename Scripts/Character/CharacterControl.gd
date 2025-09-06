class_name CharacterControl extends Control

const scene = preload("res://Assets/Character/CharacterControl.tscn")

@export var character: Character

static func create(character: Character) -> CharacterControl:
	var control: CharacterControl = scene.instantiate()
	control.character = character
	return control

func _ready():
	add_to_group("character")
