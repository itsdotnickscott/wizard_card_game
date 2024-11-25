class_name Reward extends Resource

"""
reward ideas

CURRENCY

magic dust
	- saves between runs
	- legacy upgrades

gold
	- only for current run
	- market sometimes shows up on the map

BATTLE

spellbook
	- get a new spell or spell upgrade 

tomes
	- choose from different books to gain a random spell effect

relics
	- grant passive effects for the rest of the run
	- limited number of relics or infinite?

treasure stash
	- random item
	- ie. dust, gold

arcane rune
	- brand a rune onto a card for rest of run to provide a passive effect
	- ie. extra damage or multi

ritual
	- modifying the deck
	- ie. removing cards, changing element or rank, making a card wild

card pack
	- more cards

tarot cards
	- powerful one-time effect

fountain
	- +1 mana, discard, or hand capacity
	- + max hp
	- heal

idols
	- powerful passive (or active maybe?)
	- but only one at a time
	- maybe equippable between runs

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
	SPELLBOOK
		1-card

		- Spark (Any Card)
			Lvl 1: 5 x 1.0

		2-card

		- *** Twin Bolt (1 Set of 2, Any) [Starting]
			Lvl 1: 15 x 1.0

		3-card

		- *** Elemental Weave (1 Run of 3, Match Any) [Starting]
			Lvl 1: 10 x 2.0

		- *** Chromatic Blast (1 Set of 3, Any) [Starting]
			Lvl 1: 15 x 2.0

		4-card

		- Prismatic Orb (2 Sets of 2, Any)
			Lvl 1: 20 x 2.0

		- Organic Fissure (1 Run of 4, Match Any)
			Lvl 1:

		- Intense Rapture (1 Set of 4, Any)
			Lvl 1:

		5-card

		- Unstable Thread (1 Run of 5, Match Any)
			Lvl 1:

		- Chaotic Force (1 Set of 5, Any)
			Lvl 1:

		- Natural Takeover (Any of 5, Match Any)
			Lvl 1:

		6-card

		- Rapid Rush (2 Runs of 3, Match Any)
			Lvl 1: 20 x 2.0

		- Spell Name (2 Sets of 3, Any)
			Lvl 1: 20 x 2.0
		
		- Spell Name (3 Sets of 2, Any)
			Lvl 1: 20 x 2.0
		

		
	ARCANE TOME
		 

	FIRE TOME


	WATER TOME


	EARTH TOME


	ANCIENT TOME

	"""