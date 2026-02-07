extends Node

var Shockwave = preload("res://Shockwave.tscn");

func spawn(direction : int, pos : Vector2):
	match direction:
		-1:
			var new = Shockwave.instantiate()
		1:
			var new = Shockwave.instantiate()
			
		_:
			push_error("invalid direction")	
