class_name Idol extends Resource


static var _library: Dictionary = {}


@export var name: String = ""
@export var affinity: Card.Affinity = Card.Affinity.NONE
@export var effect: Effect = null
@export var dragon_pref: Card.Affinity = Card.Affinity.NONE


func _init(new_name: String, aff: Card.Affinity, eff: Effect, dragon: Card.Affinity) -> void:
	name = new_name
	affinity = aff
	effect = eff
	dragon_pref = dragon


static func init_library() -> void:
	_library = {
		"fire": Idol.new(
			"Infernal Idol", Card.Affinity.FIRE, 
			Effect.Burn.new(Effect.Target.ENEMY, Effect.Proc.START_TURN, 10, 3),
			Card.Affinity.RED_DRAGON
		),
		"water": Idol.new(
			"Idol of Flowing", Card.Affinity.WATER,
			Effect.Heal.new(Effect.Target.PLAYER, Effect.Proc.END_TURN, 10, 1),
			Card.Affinity.WHITE_DRAGON
		),
		"earth": Idol.new(
			"Weathered Idol", Card.Affinity.EARTH,
			Effect.Shield.new(Effect.Target.PLAYER, Effect.Proc.START_TURN, 10, 1),
			Card.Affinity.GREEN_DRAGON
		)
	}


static func get_all_idols() -> Array:
	return _library.values()