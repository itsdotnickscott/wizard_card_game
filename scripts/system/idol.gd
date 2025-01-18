class_name Idol extends Resource


static var _library: Dictionary = {}


@export var name: String = ""
@export var affinity: Card.Affinity = Card.Affinity.NONE
@export var effect: Effect = null


func _init(new_name: String, aff: Card.Affinity, eff: Effect) -> void:
	name = new_name
	affinity = aff
	effect = eff


static func init_library() -> void:
	_library = {
		"fire": Idol.new(
			"Infernal Idol", Card.Affinity.FIRE, 
			Effect.Burn.new(Effect.Target.ENEMY, Effect.Proc.TURN, 10, 3)
		),
		"water": Idol.new(
			"Idol of Flowing", Card.Affinity.WATER,
			Effect.Heal.new(Effect.Target.PLAYER, Effect.Proc.TURN, 10, 1)
		),
		"earth": Idol.new(
			"Weathered Idol", Card.Affinity.EARTH,
			Effect.Shield.new(Effect.Target.PLAYER, Effect.Proc.TURN, 10, 1)
		)
	}


static func get_all_idols() -> Array[Idol]:
	var all: Array[Idol] = []
	all.assign(_library.values())
	return all