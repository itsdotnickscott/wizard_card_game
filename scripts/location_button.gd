class_name LocationButton extends Button


@onready var current_panel = get_node("CurrentPanel")

var location: Location = null


func set_current(curr: bool) -> void:
	if curr:
		text += "*"


func reveal_location_name() -> void:
	if location is Location.Battle:
		if location.enemy.tier == Enemy.Tier.BOSS:
			text = "Boss"
		elif location.enemy.tier == Enemy.Tier.ELITE:
			text = "Elite"
		else:
			text = "Battle"
	elif location is Location.Event:
		text = "Event"
	elif location is Location.Market:
		text = "Market"