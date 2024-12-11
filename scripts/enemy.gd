class_name Enemy extends Unit


enum Tier { NORMAL, ELITE, BOSS }


@export var attacks: Array[Attack]
@export var tier: Tier


func reset_enemy(info: EnemyInfo) -> void:
	name = info.name
	max_health = info.max_health
	health = max_health
	attacks = info.attacks
