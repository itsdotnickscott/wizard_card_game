class_name Upgrade extends Resource


static var _library: Dictionary = {}


var name: String
var affinity: Card.Affinity
var tome_rarity: Reward.Rarity
var effect: Effect
var spell: Spell


func _init(
	new_name: String, aff: Card.Affinity, rarity: Reward.Rarity, 
	eff: Effect,
	give_to: Spell
) -> void:
	name = new_name
	affinity = aff
	tome_rarity = rarity
	effect = eff
	spell = give_to


func level_up() -> void:
	print("Upgrade level up not implemented")
	pass


static func initialize_library() -> void:
	_library = {
		"fire_weave": Upgrade.new(
			"Flame Weave", Card.Affinity.FIRE, Reward.Rarity.COMMON,
			Effect.Burn.new(Effect.Target.ENEMY, Effect.Proc.ENEMY_END_TURN, 10, 3),
			Spell.get_from_id("weave")
		),

		"water_weave": Upgrade.new(
			"Rejuvinating Weave", Card.Affinity.WATER, Reward.Rarity.COMMON,
			Effect.Heal.new(Effect.Target.PLAYER, Effect.Proc.INSTANT, 10),
			Spell.get_from_id("weave")
		),

		"earth_weave": Upgrade.new(
			"Protective Weave", Card.Affinity.EARTH, Reward.Rarity.COMMON,
			Effect.Shield.new(Effect.Target.PLAYER, Effect.Proc.INSTANT, 20),
			Spell.get_from_id("weave")
		),

		"arcana_weave": Upgrade.new(
			"Flexi Weave", Card.Affinity.ARCANA, Reward.Rarity.COMMON,
			Effect.Wild.new(Card.Affinity.ARCANA, 1),
			Spell.get_from_id("weave")
		)
	}


func _to_string() -> String:
	return name


static func get_upgrades(aff: Card.Affinity = Card.Affinity.WILD) -> Array[Upgrade]:
	var upgrades: Array[Upgrade] = []
	for upgrade in _library.values():
		if upgrade.affinity == aff or aff == Card.Affinity.WILD:
			upgrades.append(upgrade)
	return upgrades
		