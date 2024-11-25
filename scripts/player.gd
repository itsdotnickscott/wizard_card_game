class_name Player extends Node2D


var card_scene = preload("res://scenes/card.tscn")


var max_health: int = 100
var max_mana: int = 4
var max_discards: int = 3
var hand_limit: int = 7
var select_limit: int = 4

var health: int = max_health
var mana: int = max_mana
var discards_left: int = max_discards

var deck: Array[Card] = []
var max_deck_size: int = 0
var spellbook: Array[Spell] = []

var hand: Array[Card] = []
var discard: Array[Card] = []


## Resets [member Player.mana], [member Player.discards_left], and [member Player.deck] 
## to their default values.
func battle_start() -> void:
	mana = max_mana
	discards_left = max_discards
	reset_deck()


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

	return Analysis.get_valid_spell(spellbook, selected_cards)


## Discards given [Card] objects from the [member Player.hand]. Returns [code]true[/code] if 
## discard was successful.
func discard_cards(selected_cards: Array[Card]) -> bool:
	if discards_left == 0:
		print("out of discards")
		return false

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
## split up evenly among three different elements (fire, water, earth).[br]
## Face cards that are worth 11 damage and can be used in runs before 2 and after 10.
func _create_base_deck() -> Array[Card]:
	var new_deck: Array[Card] = []

	for t in range(1):
		var val := 2
		var elem := 0

		for i in range(10):
			for j in range(4):
				var new_card: Card = card_scene.instantiate()
				new_card.init(val, elem)
				new_deck.append(new_card)
				elem += 1
			val += 1
			elem = 0

	return new_deck


## Returns three starting [Spell] objects, Twin Bolts (Set, 2 Cards, Any), Chromatic Weave
## (Run, 3 Cards, Match Any), and Elemental Blast (Set, 3 Cards, Any)).
func _create_base_spellbook() -> Array[Spell]:
	var bolt := Spell.new(
		"Twin Bolt", 
		Spell.RankCombo.SET, Spell.ElemCombo.ANY, 
		2, 1, 15, 1.0
	)
	var blast := Spell.new(
		"Chromatic Blast", 
		Spell.RankCombo.SET, 
		Spell.ElemCombo.ANY,
		3, 1, 10, 2.0
	)
	var weave := Spell.new(
		"Elemental Weave", 
		Spell.RankCombo.RUN, 
		Spell.ElemCombo.MATCH_ANY, 
		3, 1, 15, 2.0
	)

	return [bolt, blast, weave]


func _ready() -> void:
	deck = _create_base_deck()
	max_deck_size = deck.size()
	spellbook = _create_base_spellbook()
	var analysis = Analysis.new(spellbook, deck)
	analysis.analyze_spells()