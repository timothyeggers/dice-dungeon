extends Node

## Key is _get_unique_key, Value is FloatingLabel.value
var _floating_labels: Array

func get_unique_key(owner_id, keyname):
	return "%s : %s" % [owner_id, keyname]

## Add is automatically called on FloatingLabel._enter_tree() call.
func add_floating_label(owner_id: int, keyname: String, amount: float):
	var owner = instance_from_id(owner_id)
	if !owner:
		return
	
	var unique_key = get_unique_key(owner_id, keyname)
	if _floating_labels.has(unique_key):
		return
	
	print_debug("DEBUG Added FloatingLabel Owner: %s, Key: %s" % [owner_id, keyname])

## Remove is automatically called on FloatingLabel._exit_tree() call.
func remove_floating_label(owner_id: int):
	_floating_labels.erase(owner_id)

func create_floating_label(owner_id: int, keyname: String, amount: float, global_position: Vector2, attach_to: Node, color: Color = Color.BLACK):
	var unique_key = get_unique_key(owner_id, keyname)
	var is_new = true
	if _floating_labels.has(unique_key):
		is_new = false
	
	var find_label = get_tree().get_first_node_in_group(get_unique_key(owner_id, keyname))
	# Use existing label
	if find_label && is_instance_valid(find_label) && !find_label.is_queued_for_deletion() && find_label is FloatingLabel:
		var found = find_label as FloatingLabel
		found.amount += amount
		found.reset()
	# Build new label.
	else:
		var find_labels_owned_by = get_tree().get_nodes_in_group(str(owner_id))
		var offset_y = 0
		var offset_x = 0
		for l in find_labels_owned_by:
			if l is not FloatingLabel:
				continue
			offset_x += 1
			offset_y += l.size.y
		FloatingLabel.create(owner_id, keyname, amount, global_position + Vector2(offset_x, offset_y), attach_to, color)
