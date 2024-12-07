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


enum Rarity {
	COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
}

enum Type {
	NONE=-1, TOME,
}

enum Tome {
	KNOWLEDGE, INFERNAL, FLOWING, TERRA, ANCIENT,
}


static func get_random_reward(type: Type=Type.NONE) -> Dictionary:
	var rng := RandomNumberGenerator.new()

	if type == Type.NONE:
		var choice = rng.randf_range(0.0, 100.0)
		
		if choice < 100.0:
			type = Type.TOME

	match type:
		Type.TOME:
			return { Type.TOME: get_random_tome(rng) }
		_:
			return { }


static func get_random_tome(rng: RandomNumberGenerator) -> Array:
	var tome := []
	var choice := rng.randi_range(0, Tome.size() - 1)
	var size := 3

	match choice:
		Tome.KNOWLEDGE:
			while tome.size() < size:
				var spell = get_random_spell(rng)
				if not (spell in tome):
					tome.append(spell)

		_:
			while tome.size() < size:
				# Below line returns any upgrade for now, note that commented out line relies that
				# Card.Affinity WILD = 0 and elements start at 1.
				var upgrade = get_random_upgrade(rng) #get_random_upgrade(rng, choice)
				if not (upgrade in tome):
					tome.append(upgrade)

	return tome


static func get_random_spell(rng: RandomNumberGenerator) -> Spell:
	var random := rng.randf_range(0.0, 100.0)
	var spells := Spell.get_all_spells()
	var choices := []
	var rarity: Rarity

	if random < 70.0:
		rarity = Rarity.COMMON
	elif random < 90.0:
		rarity = Rarity.UNCOMMON
	elif random <= 100.0:
		rarity = Rarity.RARE

	for spell in spells:
		if spell.tome_rarity == rarity:
			choices.append(spell)

	var choice := rng.randi_range(0, choices.size() - 1)
	return choices[choice]


static func get_random_upgrade(
	rng: RandomNumberGenerator, aff: Card.Affinity = Card.Affinity.WILD
) -> Upgrade:
	var random := rng.randf_range(0.0, 100.0)
	var upgrades := Upgrade.get_upgrades(aff)
	var choices := []
	var rarity: Rarity

	if random <= 100.0:
		rarity = Rarity.COMMON

	if aff != Card.Affinity.WILD:
		for upgrade in upgrades:
			if upgrade.tome_rarity == rarity:
				choices.append(upgrade)

		var choice := rng.randi_range(0, choices.size() - 1)
		return choices[choice]
	else:
		var choice := rng.randi_range(0, upgrades.size() - 1)
		return upgrades[choice]