class_name Attack extends Resource


@export var name: String = ""
@export var damage: int = 0


func _init(new_name: String, dmg: int) -> void:
	name = new_name
	damage = dmg