extends Node

#func get_first_parent_with_tag(child_node: Node, tag_name: String, max_search = 5) -> Node:
	#var current = child_node
	#for i in max_search:
		#print(current.get_parent())
		#if (!current): break
		#print(current)
		#if (current.is_in_group(tag_name)):
			#return current
		#current = current.get_parent()
	#
	#return null

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
