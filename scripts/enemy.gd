class_name Enemy extends Node2D


var max_health: int = 100
var health: int = max_health
var attack: int = 0


func take_dmg(val: float):
	# Currently just rounding down and ignoring floating value
	health -= int(val)