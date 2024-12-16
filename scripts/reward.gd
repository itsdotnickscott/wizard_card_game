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


@export var choices: Array
@export var choice_amt: int


func _init(rewards: Array, choose: int) -> void:
	choices = rewards
	choice_amt = choose


class Tome extends Reward:
	enum Type {
		KNOWLEDGE, INFERNAL, FLOWING, TERRA, ANCIENT,
	}


	static func get_random() -> Tome:
		var rng := RandomNumberGenerator.new()
		var tome := []
		var choice := rng.randi_range(0, Type.size() - 1)
		var size := 3

		match choice:
			Type.KNOWLEDGE:
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

		return Tome.new(tome, 1)


	static func get_random_spell(rng: RandomNumberGenerator) -> Spell:
		var random := rng.randf_range(0.0, 100.0)
		var all_spells := Spell.get_all_spells()
		var spells := []
		var rarity: Rarity

		if random < 70.0:
			rarity = Rarity.COMMON
		elif random < 90.0:
			rarity = Rarity.UNCOMMON
		elif random <= 100.0:
			rarity = Rarity.RARE

		for spell in all_spells:
			if spell.tome_rarity == rarity:
				spells.append(spell)

		var choice := rng.randi_range(0, spells.size() - 1)
		return spells[choice]


	static func get_random_upgrade(
		rng: RandomNumberGenerator, aff: Card.Affinity = Card.Affinity.WILD
	) -> Upgrade:
		var random := rng.randf_range(0.0, 100.0)
		var all_upgs := Upgrade.get_upgrades(aff)
		var upgs := []
		var rarity: Rarity

		if random <= 100.0:
			rarity = Rarity.COMMON

		if aff != Card.Affinity.WILD:
			for upgrade in all_upgs:
				if upgrade.tome_rarity == rarity:
					upgs.append(upgrade)

			var choice := rng.randi_range(0, upgs.size() - 1)
			return upgs[choice]
		else:
			var choice := rng.randi_range(0, all_upgs.size() - 1)
			return all_upgs[choice]


class CardPack extends Reward:
	static var card_scene = load("res://scenes/card.tscn")


	static func get_random() -> CardPack:
		var rng := RandomNumberGenerator.new()
		var pack := []
		var size := rng.randi_range(3, 5)

		for i in range(size):
			var val := rng.randi_range(2, 11)
			var aff := rng.randi_range(1, 4)
			var card: Card = card_scene.instantiate()
			card.init(val, aff)
			pack.append(card)

		return CardPack.new(pack, 1)


class TarotPack extends Reward:
	static func get_random() -> TarotPack:
		var rng := RandomNumberGenerator.new()
		var all_tarots := Tarot.get_all_tarots()
		var pack := []
		var size := 3

		while pack.size() < size:
			var choice = rng.randi_range(0, all_tarots.size() - 1)
			if not all_tarots[choice] in pack:
				pack.append(all_tarots[choice])

		return TarotPack.new(pack, 1)