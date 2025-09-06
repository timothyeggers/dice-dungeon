class_name AvoidanceManager extends Node
"""
AvoidanceManager processes all registered AvoidanceComponent, updating a fixed amount per frame
in order to increase performance.
"""

@export var max_updates = 80

var _component_s: Array[AvoidanceComponent] = []
var _component_s_priority: Array[AvoidanceComponent] = []

var _update_index = 0


func add_component(component : AvoidanceComponent, high_priority := false):
	if high_priority:
		_component_s_priority.append(component)
	else:
		_component_s.append(component)

func _physics_process(delta):
	# update component's!
	var start_i = _update_index
	var count = len(_component_s)
	count = clamp(count, count, max_updates)
	for i in count:
		if _update_index >= len(_component_s):
			_update_index = 0
		
		var component = _component_s[_update_index]
		
		# clean up non existant component
		if not weakref(component).get_ref():
			_component_s.remove_at(_update_index)
			_update_index -= 1
			continue
		
		component.update_avoidance()
		_update_index += 1
	
	# update priority component's
	count = len(_component_s_priority)
	var i = 0
	for none in count:
		if i >= len(_component_s_priority):
			i = 0
			
		var component = _component_s_priority[i]
		
		# clean up non existant component
		if not weakref(component).get_ref():
			_component_s_priority.remove_at(i)
			i -= 1
			continue
		
		component.update_avoidance()
		i += 1
	
