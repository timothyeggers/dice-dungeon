extends Node

static var rooms_completed := 0

const battle_scene := preload("res://Assets/BattleScreen/Battlescreen.tscn")
const overworld_scene := preload("res://Assets/Overworld/Overworld.tscn")

func get_world() -> Node2D:
	# Do a search for first node2d if it isnt set?
	var world = get_tree().get_first_node_in_group("World")
	return world

func get_battle_manager() -> BattleManager:
	var bm = get_tree().get_first_node_in_group("BattleManager")
	return bm

func change_scene_to_node(node):
	var tree = get_tree()
	var cur_scene = tree.get_current_scene()
	tree.get_root().add_child(node)
	tree.get_root().remove_child(cur_scene)
	tree.set_current_scene(node)

func start_battle(data: PathData):
	# Reset Mouse Cursor
	Input.set_custom_mouse_cursor(null)
	
	print("Rooms Completed: %s" % rooms_completed)
	var new_scene = battle_scene.instantiate()
	var bm = new_scene.get_child(0)
	bm.data = data
	change_scene_to_node(new_scene)
	
	data.threat_level += 1

func start_overworld():
	# Reset Mouse Cursor
	Input.set_custom_mouse_cursor(null)
	
	rooms_completed += 1
	var new_scene = overworld_scene.instantiate()
	change_scene_to_node(new_scene)
	print("Rooms Completed: %s" % rooms_completed)
	
