class_name Stopwatch
extends Resource

static func time(callable: Callable, output: bool = true) -> int:
	var tick_a = Time.get_ticks_msec()
	callable.call()
	var tick_b = Time.get_ticks_msec()
	var tick_e = tick_b - tick_a
	if output:
		print_rich("[color=red][b]", callable.get_method(), "[/b][/color]", " completed in ", tick_e, " ms.")
	
	return tick_e
