## DamageReceiverManager is currently dicked at the end of player turn.
extends Node

var _components : Array[DamageReceiverComponent] = []

func add(component: DamageReceiverComponent):
	_components.append(component)

func remove(component: DamageReceiverComponent):
	for i in _components.size():
		if _components[i] == component:
			_components.remove_at(i)
			return

func tick():
	for c in _components:
		c.tick()
