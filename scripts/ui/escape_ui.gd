extends Control


signal escape(val: int)


@onready var escape_label = get_node("EscapePanel/Escape")


var damage: int


func set_escape_damage(val: int) -> void:
	damage = val
	escape_label.text = "Escape ( -%d Health )" % [val]


func _on_escape_pressed() -> void:
	escape.emit(damage)
