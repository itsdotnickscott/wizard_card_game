extends Control


signal escape(val: int)


var damage: int


func set_escape_damage(val: int) -> void:
	damage = val
	get_node("EscapePanel/Escape").text = "Escape ( -%d Health )" % [val]


func _on_escape_pressed() -> void:
	escape.emit(damage)
