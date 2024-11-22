class_name Player extends Node2D


var card_scene = preload("res://scenes/card.tscn")


var max_health: int = 100
var max_mana: int = 4
var max_discards: int = 3
var hand_limit: int = 5
var select_limit: int = 3

var health: int = max_health
var mana: int = max_mana
var discards_left: int = max_discards

var deck: Array[Card] = []
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
## Returns [code]true[/code] if [Player] has more mana (>0) left.
func cast_cards(selected_cards: Array[Card]) -> bool:
	# Check for enough mana
	if mana == 0:
		print("out of mana")
		return false

	# Check for valid spell in spellbook
	var valid = valid_spells(selected_cards)
	print(valid)

	for i in range(spellbook.size()):
		if valid[i]:
			print(spellbook[i].name + " - ", calc_dmg(spellbook[i], selected_cards))

	mana -= 1
	for card in selected_cards:
		hand.erase(card)
		discard.append(card)

	return mana > 0


func calc_dmg(spell: Spell, selected_cards: Array[Card]):
	var base = 0.0

	for card in selected_cards:
		base += card.value

	return base * spell.multi


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
			return false
	
	return true


## Returns [code][true][/code] if every [Card] in [param selected_cards] are in ascending
## [member Card.value].
func valid_run(selected_cards: Array[Card]) -> bool:
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
	var next = deck.pop_front()

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
	var asc_value = func (a: Card, b: Card) -> int:
		if by_value:
			return a.value < b.value
		else:
			return a.element < b.element

	cards.sort_custom(asc_value)


## Returns a 30-card_scene [Deck], with six of each value (2-6) split up evenly
## among three different elements (fire, water, earth).
func _create_base_deck() -> Array[Card]:
	var new_deck: Array[Card] = []

	var val: int = 2
	var elem: int = 0

	for i in range(5):
		for j in range(6):
			var new_card = card_scene.instantiate()
			new_card.init(val, elem)
			new_deck.append(new_card)
			elem = (elem + 1) % 3
		val += 1
		elem = 0

	return new_deck


## Returns three starting [Spell] objects, Twin Bolts (Set, 2 Cards, Any), Chromatic Weave
## (Run, 3 Cards, Match Any), and Elemental Blast (Set, 3 Cards, Any)).
func _create_base_spellbook() -> Array[Spell]:
	var bolt = Spell.new("Twin Bolt", Spell.ValCombo.SET, Spell.ElemCombo.ANY, 2, 1.0)
	var weave = Spell.new("Elemental Weave", Spell.ValCombo.RUN, Spell.ElemCombo.MATCH_ANY, 3, 1.0)
	var blast = Spell.new("Chromatic Blast", Spell.ValCombo.SET, Spell.ElemCombo.ANY, 3, 1.25)

	return [bolt, weave, blast]


func spell_analysis() -> void:
	for spell in spellbook:
		print(spell.name)

		if spell.val_combo == Spell.ValCombo.SET:
			print("min damage: ", (2 * spell.card_amt) * spell.multi)
			print("avg damage: ", (4 * spell.card_amt) * spell.multi)
			print("max damage: ", (6 * spell.card_amt) * spell.multi)

		elif spell.val_combo == Spell.ValCombo.RUN:
			print("min damage: ", (3 * spell.card_amt) * spell.multi)
			print("avg damage: ", (4 * spell.card_amt) * spell.multi)
			print("max damage: ", (5 * spell.card_amt) * spell.multi)

		print()


func _ready() -> void:
	deck = _create_base_deck()
	spellbook = _create_base_spellbook()
	spell_analysis()