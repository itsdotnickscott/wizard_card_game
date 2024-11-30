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
	COMMON, UNCOMMON, RARE, EPIC
}

enum Type {
	TOME,
}


static func get_random_reward(type: Type) -> Variant:
	var rng := RandomNumberGenerator.new()

	match type:
		Type.TOME:
			return get_random_tome(rng)
		_:
			return null


static func get_random_rewards(quantity: int, type: Type) -> Dictionary:
	var choices := {}
	while choices.size() < quantity:
		var reward = get_random_reward(type)
		if not reward.name in choices.keys():
			choices[reward.name] = reward
	return choices


static func get_random_tome(rng: RandomNumberGenerator) -> Spell:
	var random := rng.randf_range(0.0, 100.0)
	var spells := Spell.get_all_spells()
	var choices := []
	var rarity: Rarity

	if random < 70.0:
		rarity = Rarity.COMMON
	elif random < 90.0:
		rarity = Rarity.UNCOMMON
	elif random < 99.0:
		rarity = Rarity.RARE
	else:
		rarity = Rarity.RARE
		print("rolled epic spell, no epic spell available, returning rare spell for now")

	for spell in spells:
		if spell.tome_rarity == rarity:
			choices.append(spell)

	var choice := rng.randi_range(0, choices.size() - 1)
	return choices[choice]