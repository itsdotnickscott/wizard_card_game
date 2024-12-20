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
	static func name() -> String:
		return "Tome"


	static func get_random() -> Tome:
		var rng := RandomNumberGenerator.new()
		var tome := []
		var size := 3

		while tome.size() < size:
			var spell = get_random_spell(rng)
			if not (spell in tome):
				tome.append(spell)

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


class ChooseIdol extends Reward:
	static func name() -> String:
		return "Choose Idol"


	static func get_random() -> ChooseIdol:
		var rng := RandomNumberGenerator.new()
		var all_idols := Idol.get_all_idols()
		var pack := []
		var size := 2

		while pack.size() < size:
			var choice = rng.randi_range(0, all_idols.size() - 1)
			if not all_idols[choice] in pack:
				pack.append(all_idols[choice])

		return ChooseIdol.new(pack, 1)


class CardPack extends Reward:
	static var card_scene = load("res://scenes/card.tscn")


	static func name() -> String:
		return "Card Pack"


	static func get_random(player: Player) -> CardPack:
		var rng := RandomNumberGenerator.new()
		var pack := []
		var size := rng.randi_range(3, 5)

		for i in range(size):
			var chance := rng.randf_range(0.0, 100.0)
			var card: Card = null

			if chance < 5.0: # Dragon Card
				var aff: Card.Affinity = player.get_curr_drags().pick_random()
				card = Card.new(Card.Type.DRAGON, aff)
				
			elif chance < 25.0: # Wind Card
				var dir := rng.randi_range(1, 4)
				card = Card.new(Card.Type.WIND, dir)
			else:
				var val := rng.randi_range(Card.MIN_RANK, Card.BRIDGE_RANK - 1)
				var aff: Card.Affinity = player.get_curr_affs().pick_random()
				card = Card.new(Card.Type.NUMBER, aff, val)

			pack.append(card)

		return CardPack.new(pack, 1)


class TarotPack extends Reward:
	static func name() -> String:
		return "Tarot Card Pack"


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