class_name Abilities extends Node

static func basic_sweep_attack(targets: Array[DamageReceiver], params: DamageData):
	for target in targets:
		if (target is DamageReceiver):
			target.receive(params)

static func basic_attack(target: DamageReceiver, params: DamageData):
	target.receive(params)

static func basic_defensive(target: DamageReceiver, params: BuffData):
	target.buff(params)
