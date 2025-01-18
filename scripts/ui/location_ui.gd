extends Control


signal location_pressed(location: Location)


@onready var button: Button = get_node("Button")
@export var info: Location = null


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


func set_location(location: Location) -> void:
	info = location


func _on_location_pressed() -> void:
	location_pressed.emit(info)
