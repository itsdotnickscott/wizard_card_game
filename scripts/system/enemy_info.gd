class_name EnemyInfo extends Resource


@export var name: String = ""
@export var tier: Enemy.Tier = Enemy.Tier.NORMAL
@export var max_health: int = 100


func _init(new_name: String, type: Enemy.Tier, hp: int) -> void:
	name = new_name
	tier = type
	max_health = hp