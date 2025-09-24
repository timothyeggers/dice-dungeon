extends Node

## Returns a random float between 0-1.
func get_random(rerolls := 0) -> float:
	var value = randf()
	print_debug("DEBUG Rolled %s" % value)
	for i in rerolls:
		var reroll = randf()
		print_debug("DEBUG Rerolled %s" % reroll)
		if reroll > value:
			value = reroll
		
	return value
