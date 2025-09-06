extends Node

func get_first_child_with_tag(parent_node: Node, tag_name: String) -> Node:
	for child in parent_node.get_children():
		# Check if the child node has the specified tag
		if child.is_in_group(tag_name):
			print("Fag")
			return child
	return null

func get_children_with_tag(parent_node: Node, tag_name: String) -> Array[Node]:
	var nodes_with_tag = []
	for child in parent_node.get_children():
		# Check if the child node has the specified tag
		if child.is_in_group(tag_name):
			nodes_with_tag.append(child)
	return nodes_with_tag
