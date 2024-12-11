class_name EnemyInfo extends Resource


@export var name: String = ""
@export var tier: Enemy.Tier = Enemy.Tier.NORMAL
@export var max_health: int = 100
@export var attacks: Array[Attack] = []


func _init(new_name: String, type: Enemy.Tier, hp: int, atks: Array[Attack]) -> void:
	name = new_name
	tier = type
	max_health = hp
	attacks = atks