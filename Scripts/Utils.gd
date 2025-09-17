extends Node

func is_type(res, type) -> bool:
	if type is String:
		return res is Node and res.get_class() == type
	return typeof(res) == type

func get_children_of_type(parent_node: Node, typeName: String):
	var children = []
	for child in get_all_children(parent_node):
		if is_type(child, typeName):
			print("Is type")
			children.append(child)
	return children

func get_child_of_type(parent_node: Node, typeName: String):
	for child in get_all_children(parent_node):
		if is_type(child, typeName):
			print("Is type")
			return child
	return null

func get_first_child_with_tag(parent_node: Node, tag_name: String) -> Node:
	for child in Utils.get_all_children(parent_node):
		# Check if the child node has the specified tag
		if child.is_in_group(tag_name):
			return child
	return null

func get_children_with_tag(parent_node: Node, tag_name: String) -> Array:
	var nodes_with_tag = []
	for child in Utils.get_all_children(parent_node):
		# Check if the child node has the specified tag
		if child.is_in_group(tag_name):
			nodes_with_tag.append(child)
	return nodes_with_tag

func get_all_children(parent: Node) -> Array:
	var nodes : Array = []
	for child in parent.get_children():
		if child.get_child_count() > 0:
			nodes.append(child)
			nodes.append_array(get_all_children(child))
		else:
			nodes.append(child)
	return nodes
