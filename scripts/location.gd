class_name Location extends Resource


@export var links: Array[Location] = []


func set_links(locations: Array[Location]) -> void:
	links = locations


class Battle extends Location:
	@export var enemy: EnemyInfo = null
	@export var reward: Dictionary = {}


	func _init(enemy_info: EnemyInfo, win: Dictionary) -> void:
		enemy = enemy_info
		reward = win


class Event extends Location:
	var event


class Market extends Location:
	var items
