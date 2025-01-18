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
	TOME, CHOOSE_IDOL, CARD_PACK, TAROT_PACK, CHOOSE_RELIC
}


enum Rarity {
	COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
}


@export var choices: Array
@export var choice_amt: int
static var rng := RandomNumberGenerator.new()


static func get_random(type: Type, player: Player) -> Reward:
	match type:
		Type.TOME:
			return Tome.random()
		Type.CHOOSE_IDOL:
			return ChooseIdol.random()
		Type.CARD_PACK:
			return CardPack.random(player)
		Type.TAROT_PACK:
			return TarotPack.random()
		Type.CHOOSE_RELIC:
			return ChooseRelic.random()
		_:
			return null


static func get_random_pack(library: Array[Variant], size: int) -> Array[Variant]:
	var pack := []

	while pack.size() < size:
		var choice = rng.randi_range(0, library.size() - 1)
		if not library[choice] in pack:
			pack.append(library[choice])

	return pack


static func to_str(type: Type) -> String:
	match type:
		Type.TOME:
			return "Tome"
		Type.CHOOSE_IDOL:
			return "Choose Idol"
		Type.CARD_PACK:
			return "Card Pack"
		Type.TAROT_PACK:
			return "Tarot Pack"
		Type.CHOOSE_RELIC:
			return "Choose Relic"
		_:
			return "_"


func _init(rewards: Array, choose: int) -> void:
	choices = rewards
	choice_amt = choose


class Tome extends Reward:
	static func random() -> Tome:
		return Tome.new(get_random_pack(Spell.get_all_spells(), 3), 1)


class ChooseIdol extends Reward:
	static func random() -> ChooseIdol:
		return ChooseIdol.new(get_random_pack(Idol.get_all_idols(), 3), 1)


class CardPack extends Reward:
	static func random(player: Player) -> CardPack:
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
	static func random() -> TarotPack:
		return TarotPack.new(get_random_pack(Tarot.get_all_tarots(), 3), 1)


class ChooseRelic extends Reward:
	static func random() -> ChooseRelic:
		return ChooseRelic.new(get_random_pack(Relic.get_all_relics(), 3), 1)