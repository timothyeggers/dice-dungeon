## EnemyManager for EnemyControl.
extends Node

# Contains an array of get_instance_id() of EnemyControls instantiated in scene.
var _enemies_ids : Array

## EnemyManager.add() is automatically called on EnemyControl._ready() call.
func add(owner_instance_id: int):
	if _enemies_ids.has(owner_instance_id):
		return

	if !is_instance_id_valid(owner_instance_id):
		return
	
	if instance_from_id(owner_instance_id) is not EnemyControl:
		print_debug("ERROR Tried to append instance %s to Enemy manager but was not of type EnemyControl." % owner_instance_id)
		return
	
	_enemies_ids.append(owner_instance_id)
	print_debug("DEBUG Added Enemy in Combat for Owner: %s" % owner_instance_id)

## EnemyControl calls EnemyManager.remove() on itself when killed.
func remove(owner_instance_id: int):
	_enemies_ids.erase(owner_instance_id)

func get_all() -> Array[EnemyControl]:
	var valid : Array[EnemyControl] = []
	for enemy in _enemies_ids:
		var e = instance_from_id(enemy)
		if is_instance_valid(e) && e is EnemyControl:
			valid.append(e)
	
	return valid

## Returns all tracked EnemyControls that are still valid in scene and not queued for deletion.
func get_all_alive() -> Array[EnemyControl]:
	var valid : Array[EnemyControl] = []
	for enemy in _enemies_ids:
		var e = instance_from_id(enemy)
		if is_instance_valid(e) && e is EnemyControl && e.is_alive():
			valid.append(e)
	
	return valid
