class_name Player extends Node2D


var card_scene = preload("res://scenes/card.tscn")


var max_health: int = 100
var max_mana: int = 4
var max_discards: int = 3
var hand_limit: int = 7
var select_limit: int = 3

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
## Returns [code]true[/code] if cast was successful.
func cast_cards(selected_cards: Array[Card]) -> bool:
	# Check for enough mana
	if mana == 0:
		print("out of mana")
		return false

	mana -= 1

	for card in selected_cards:
		hand.erase(card)
		discard.append(card)

	return true


## Given an [Array] of [Card] objects, find the spell matching the selection and calculate its
## damage value.
func calc_dmg(selected_cards: Array[Card]) -> float:
	var base:= 0.0

	# Check for valid spell in spellbook
	var valid := valid_spells(selected_cards)

	for i in range(spellbook.size()):
		if valid[i]:
			for card in selected_cards:
				base += card.value

			print(spellbook[i].name + " - ", base * spellbook[i].multi)

			return base * spellbook[i].multi

	return 0


## Returns an [Array] of booleans, [code][true][/code] for every [Spell] that can currently score.
func valid_spells(selected_cards: Array[Card]) -> Array[bool]:
	var valid: Array[bool] = []

	for spell in spellbook:
		if spell.card_amt != selected_cards.size():
			valid.append(false)
			continue

		sort_cards(selected_cards, true)
		match spell.val_combo:
			Spell.ValCombo.SET: 
				if not valid_set(selected_cards):
					valid.append(false)
					continue

			Spell.ValCombo.RUN: 
				if not valid_run(selected_cards):
					valid.append(false)
					continue

		sort_cards(selected_cards, false)
		match spell.elem_combo:
			# Spell.ElemCombo.ANY can never be invalid

			Spell.ElemCombo.MATCH_ANY: 
				if not valid_match_any(selected_cards):
					valid.append(false)
					continue

		valid.append(true)

	return valid


## Returns [code][true][/code] if every [Card] in [param selected_cards] have the same
## [member Card.value].
func valid_set(selected_cards: Array[Card]) -> bool:
	for i in range(selected_cards.size() - 1):
		if selected_cards[i].value != selected_cards[i + 1].value:
			if i == selected_cards.size() - 2 and selected_cards[0].value != 2:
				return false
	
	return true


## Returns [code][true][/code] if every [Card] in [param selected_cards] are in ascending
## [member Card.value].
func valid_run(selected_cards: Array[Card]) -> bool:
	# TODO: Implement face card (W)
	for i in range(selected_cards.size() - 1):
		if selected_cards[i].value != (selected_cards[i + 1].value - 1):
			return false
	
	return true


## Returns [code][true][/code] if every [Card] in [param selected_cards] have the same
## [member Card.element].
func valid_match_any(selected_cards: Array[Card]) -> bool:
	for i in range(selected_cards.size() - 1):
		if selected_cards[i].element != selected_cards[i + 1].element:
			return false
	
	return true


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


## Sorts [member Player.hand] by [member Card.value] if [param by_value] is [code]true[/code].
## Otherwise, it sorts it by [member Card.element]. Modifies the existing [Array].
func sort_cards(cards: Array[Card], by_value: bool) -> void:
	var asc_value := func (a: Card, b: Card) -> int:
		if by_value:
			return a.value < b.value
		else:
			return a.element < b.element

	cards.sort_custom(asc_value)


## Returns a 30-card_scene [Deck], with three of each value (2-10), and a Face card (W)
## split up evenly among three different elements (fire, water, earth).[br]
## Face cards that are worth 11 damage and can be used in runs before 2 and after 10.
func _create_base_deck() -> Array[Card]:
	var new_deck: Array[Card] = []

	var val := 2
	var elem := 0

	for i in range(10):
		for j in range(3):
			var new_card: Card = card_scene.instantiate()
			new_card.init(val, elem)
			new_deck.append(new_card)
			elem = (elem + 1)
		val += 1
		elem = 0

	return new_deck


## Returns three starting [Spell] objects, Twin Bolts (Set, 2 Cards, Any), Chromatic Weave
## (Run, 3 Cards, Match Any), and Elemental Blast (Set, 3 Cards, Any)).
func _create_base_spellbook() -> Array[Spell]:
	var bolt := Spell.new("Twin Bolt", Spell.ValCombo.SET, Spell.ElemCombo.ANY, 2, 0.5)
	var weave := Spell.new("Elemental Weave", Spell.ValCombo.RUN, Spell.ElemCombo.MATCH_ANY, 3, 1.0)
	var blast := Spell.new("Chromatic Blast", Spell.ValCombo.SET, Spell.ElemCombo.ANY, 3, 1.25)

	return [bolt, weave, blast]


func _spell_analysis() -> void:
	for spell in spellbook:
		print(spell.name)

		if spell.val_combo == Spell.ValCombo.SET:
			print("min damage: ", (2 * spell.card_amt) * spell.multi)
			print("avg damage: ", (6 * spell.card_amt) * spell.multi)
			print("max damage: ", (10 * spell.card_amt) * spell.multi)

		elif spell.val_combo == Spell.ValCombo.RUN:
			print("min damage: ", (3 * spell.card_amt) * spell.multi)
			print("avg damage: ", (6 * spell.card_amt) * spell.multi)
			print("max damage: ", (9 * spell.card_amt) * spell.multi)

		print()


func _ready() -> void:
	deck = _create_base_deck()
	max_deck_size = deck.size()
	spellbook = _create_base_spellbook()
	#_spell_analysis()