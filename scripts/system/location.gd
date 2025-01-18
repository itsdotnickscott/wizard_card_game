class_name Location extends Resource


@export var links: Array[Location] = []


func set_links(locations: Array[Location]) -> void:
	links = locations


class Fight extends Location:
	@export var enemy: EnemyInfo = null
	@export var rewards: Array[Reward.Type] = []
	@export var gold: int = 0
	@export var dust: int = 0


	func _init(
		enemy_info: EnemyInfo, loot: Array[Reward.Type], drop_gold: int = 10, drop_dust: int = 10
	) -> void:
		enemy = enemy_info
		rewards = loot
		gold = drop_gold
		dust = drop_dust


class Incident extends Location:
	var incident


class Market extends Location:
	var items
