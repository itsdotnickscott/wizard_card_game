class_name Player extends Node2D


var card_scene = preload("res://scenes/card.tscn")


var max_health: int = 100
var max_mana: int = 4
var max_discards: int = 3
var hand_limit: int = 6
var select_limit: int = 3

var health: int = max_health
var mana: int = max_mana
var discards_left: int = max_discards

var deck: Array[Card] = []
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
	if mana == 0:
		print("out of mana")
		return false

	mana -= 1
	for card in selected_cards:
		hand.erase(card)
		discard.append(card)

	return mana > 0


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


## Sorts [member Player.hand] by [Card] value or element.
func sort_hand(by_value: bool) -> void:
	var asc_value = func (a: Card, b: Card) -> int:
		if by_value:
			return a.value < b.value
		else:
			return a.element < b.element

	hand.sort_custom(asc_value)


## Returns a 28-card_scene [Deck], with three of each value (2-10) in three different elements
## (fire, water, earth), plus one Joker card_scene (represented by value 11).
func _create_base_deck() -> Array[Card]:
	var new_deck: Array[Card] = []

	# Adds 2-10 with three elements (fire, water, earth)
	var val: int = 2
	var elem: int = 0

	for i in range(9):
		for j in range(3):
			var new_card = card_scene.instantiate()
			new_card.init(val, elem)
			new_deck.append(new_card)
			elem += 1
		val += 1
		elem = 0

	# Adds one Joker
	var joker = card_scene.instantiate()
	joker.init(11, Card.Element.WILD)
	new_deck.append(joker)

	return new_deck


func _ready() -> void:
	deck = _create_base_deck()
