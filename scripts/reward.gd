class_name Reward extends Resource

"""
reward ideas

tomes
	- should be one of the main ones
	- choose from different books to gain a random spell or spell upgrade

magic dust
	- currency
	- saves between runs

gold
	- currency
	- only for current run
	- market sometimes shows up on the map

fountain
	- +1 mana or discard capacity



relics
	- grant passive effects for the rest of the run
	- limited number of relics or infinite?

arcane rune
	- brand a rune onto a card for rest of run to provide a passive effect

card enchantment
	- like arcane rune but different categories/rarities

tarot cards
	- powerful one-time effect

idols
	- powerful passive (or active maybe?)
	- but only one at a time

medic
	- heal

trial
	- fight another enemy for a stronger reward

"""


enum Type {
	TOME,
}


var type: Type


func _init(reward: Type) -> void:
	type = reward


func gain_reward() -> void:
	pass

	"""
	ARCANE TOME
		- Twin Bolt (Starting) (Set, Any, 2)
			Lvl 1: 0.5 Multi 

		- Elemental Weave (Starting) (Run, Match Any, 3)
			Lvl 1: 1.0 Multi

		- Chromatic Blast (Starting) (Set, Any, 3)
			Lvl 1: 1.25 Multi


	FIRE TOME


	WATER TOME


	EARTH TOME


	ANCIENT TOME

	"""