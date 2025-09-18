class_name Abilities extends Node

static func basic_sweep_attack(targets: Array[DamageReceiverComponent], params: DamageData):
	for target in targets:
		if (target is DamageReceiverComponent):
			target.receive(params)

static func basic_attack(target: DamageReceiverComponent, params: DamageData):
	target.receive(params)

static func basic_defensive(target: DamageReceiverComponent, params: BuffData):
	target.buff(params)
