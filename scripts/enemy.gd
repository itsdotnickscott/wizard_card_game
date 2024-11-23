class_name Enemy extends Node2D


var max_health: int = 30
var health: int = max_health


func take_dmg(val: float):
	# Currently just rounding down and ignoring floating value
	health -= int(val)