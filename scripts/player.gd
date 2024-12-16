class_name Player extends Unit


@onready var card_scene = preload("res://scenes/card.tscn")


@export var max_mana: int = 4
@export var max_discards: int = 3
@export var hand_limit: int = 7
@export var select_limit: int = 4

@export var deck: Array[Card] = []
@export var spellbook: Array[Spell] = []
@export var tarots: Array[Tarot] = []

var mana: int = max_mana
var discards_left: int = max_discards

var deck_size: int = 0

var hand: Array[Card] = []
var discard: Array[Card] = []

var spell_check_effects: Array[Effect] = []


## Resets [member Player.mana], [member Player.discards_left], and [member Player.deck] 
## to their default values.
func battle_start() -> void:
	super()
	mana = max_mana
	discards_left = max_discards
	
	set_up_spell_checks()

	reset_deck()


## Sets the [member Player.spell_check_effects] to all active effects from spell upgrades.
func set_up_spell_checks() -> void:
	spell_check_effects = []

	for spell in spellbook:
		for upgrade in spell.upgrades:
			for effect in upgrade.effects:
				if effect.proc == Effect.Proc.SPELL_CHECK:
					spell_check_effects.append(effect)


## Removes 1 [member Player.mana] and discards given [Card] objects from the [member Player.hand].
## Returns the [Spell] cast if successful, [code]null[/code] if no [Spell] was cast.
func cast_cards(selected_cards: Array[Card]) -> Spell:
	# Check for enough mana
	if mana == 0:
		print("out of mana")
		return null

	mana -= 1

	for card in selected_cards:
		hand.erase(card)
		discard.append(card)

	return Analysis.get_valid_spell(spellbook, selected_cards, true, spell_check_effects)


## Discards given [Card] objects from the [member Player.hand]. Returns [code]true[/code] if 
## discard was successful.
func discard_cards(selected_cards: Array[Card]) -> bool:
	if discards_left == 0:
		print("out of discards")
		#return false

	discards_left -= 1
	for card in selected_cards:
		hand.erase(card)
		discard.append(card)

	return true


## Draw [Card] objects from the top of the [member Player.deck] until the player has 
## reached the [member Player.hand_limit].
func draw_to_limit() -> void:
	while hand.size() < hand_limit:
		draw_card_to_hand()


## Draws the top [Card] of the [member Player.deck] to the [member Player.hand]. Returns
## the [Card] drawn.
func draw_card_to_hand() -> Card:
	var next: Card = deck.pop_front()

	if next == null:
		print("can't draw card, deck empty")
		return null

	hand.append(next)
	return next


## Empty [member Player.hand] and [member Player.discard], then shuffle [member Player.deck].
func reset_deck() -> void:
	deck += hand
	hand = []

	deck += discard
	discard = []
	
	deck.shuffle()


## Returns a 30-card_scene [Deck], with three of each value (2-10), and a Face card (W)
## split up evenly among three different affinities (fire, water, earth).[br]
## Face cards that are worth 11 damage and can be used in runs before 2 and after 10.
func _create_base_deck() -> Array[Card]:
	var new_deck: Array[Card] = []

	var val := 2
	var aff := 1

	for i in range(10):
		for j in range(4):
			var new_card: Card = card_scene.instantiate()
			new_card.init(val, aff)
			new_deck.append(new_card)
			aff += 1
		val += 1
		aff = 1

	return new_deck


## Returns three starting [Spell] objects, Twin Bolts (Set, 2 Cards, Any), Chromatic Weave
## (Run, 3 Cards, Match Any), and Elemental Blast (Set, 3 Cards, Any)).
func _create_base_spellbook() -> Array[Spell]:
	return [
		Spell.get_from_id("spark"), 
		Spell.get_from_id("bolt"),  
		Spell.get_from_id("blast"), 
		Spell.get_from_id("weave"), 
	]


func initialize() -> void:
	deck = _create_base_deck()
	deck_size = deck.size()
	#spellbook = Spell.get_all_spells() 
	spellbook = _create_base_spellbook()