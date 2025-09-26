class_name TargetSelector extends Line2D

static func create(origin: Vector2, attach_to: Node2D) -> TargetSelector:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var scene = load("res://Assets/TargetSelector/TargetSelector.tscn")
	var control: TargetSelector = scene.instantiate()
	control.position = origin
	control.set_point_position(0, origin)
	control.set_point_position(1, attach_to.get_local_mouse_position())
	
	attach_to.add_child(control)
	
	return control

func _ready():
	clear_points()
	add_point(Vector2.ZERO)
	add_point(get_local_mouse_position())

func _process(delta: float) -> void:
	set_point_position(1, get_local_mouse_position())
