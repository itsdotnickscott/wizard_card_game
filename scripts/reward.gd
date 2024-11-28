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


static func get_random_reward(type: Type) -> Variant:
	var rng := RandomNumberGenerator.new()

	match type:
		Type.TOME:
			var i := rng.randi_range(0, Spell.get_spell_library().size() - 1)
			return Spell.get_spell_library().values()[i]
		_:
			return null


static func get_random_rewards(quantity: int, type: Type) -> Array:
	var choices := []
	while choices.size() < quantity:
		var reward = get_random_reward(type)
		if not reward in choices:
			choices.append(reward)
	return choices