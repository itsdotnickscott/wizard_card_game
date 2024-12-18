class_name Location extends Control


@onready var button: Button = get_node("Button")


@export var info: Location = null
@export var links: Array[Location] = []


func init_as_fight(enemy_info: EnemyInfo, loot: Array[Reward], locations: Array[Location]) -> void:
	info = Fight.new(enemy_info, loot)
	links = locations


func init_as_incident(locations: Array[Location]) -> void:
	info = Incident.new()
	links = locations


func init_as_market(locations: Array[Location]) -> void:
	info = Market.new()
	links = locations


func set_current(curr: bool) -> void:
	if curr:
		button.text += "*"


func set_disabled(disabled: bool) -> void:
	button.disabled = disabled


func reveal_name() -> void:
	if info is Location.Fight:
		if info.enemy.tier == Enemy.Tier.BOSS:
			button.text = "Boss"
		elif info.enemy.tier == Enemy.Tier.ELITE:
			button.text = "Elite"
		else:
			button.text = "Battle"
	elif info is Location.Incident:
		button.text = "Event"
	elif info is Location.Market:
		button.text = "Market"


class Fight extends Location:
	@export var enemy: EnemyInfo = null
	@export var rewards: Array[Reward] = []
	@export var gold: int = 0
	@export var dust: int = 0


	func _init(
		enemy_info: EnemyInfo, loot: Array[Reward], drop_gold: int = 10, drop_dust: int = 10
	) -> void:
		enemy = enemy_info
		rewards = loot
		gold = drop_gold
		dust = drop_dust


class Incident extends Location:
	var incident


class Market extends Location:
	var items
