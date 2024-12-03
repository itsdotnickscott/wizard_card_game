class_name Unit extends Node2D


var max_health: int = 100

var health: int = max_health
var shield: float = 0


func take_dmg(val: float):
	# Currently just rounding down and ignoring floating value
	health -= int(val)


func heal(val: float):
	# Currently just rounding down and ignoring floating value
	health += int(val)


func gain_shield(val: float):
	shield += int(val)