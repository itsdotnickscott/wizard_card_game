class_name Analysis extends Resource


const LOW_CARD = 2
const HIGH_CARD = 11


var spellbook: Array[Spell]
var deck: Array[Card]


func _init(spells: Array[Spell], cards: Array[Card]) -> void:
	spellbook = spells
	deck = cards


## Prints out details of each spell into the console.
func analyze_spells() -> void:
	for spell in spellbook:
		print_spell_info(spell)
		calc_dmg_stats(spell)
		sample_probabilities(spell)
		print()


## Prints the title and hand composition of a [param spell] onto the console.
func print_spell_info(spell: Spell) -> void:
	var subtitle := str(spell.quantity) + " "

	match spell.rank_combo:
		Spell.RankCombo.SET:
			subtitle += "SET"
		Spell.RankCombo.RUN:
			subtitle += "RUN"

	subtitle += " of %d " % [spell.card_amt]

	match spell.elem_combo:
		Spell.ElemCombo.ANY:
			subtitle += "ANY"
		Spell.ElemCombo.MATCH_ANY:
			subtitle += "MATCH ANY"

	print(spell.name + " | " + subtitle)

## Given an [Array] of [Card] objects, find the spell matching the selection and calculate its
## damage value.
static func calc_dmg(hand: Array[Card], spell: Spell) -> float:
	# Check for valid spell in spellbook
	if is_valid_spell(spell, hand):
		var base: int = spell.base

		for card in hand:
			base += card.rank

		var dmg = base * spell.multi

		print(spell.name + " - ", dmg)

		return dmg

	return 0


## Given a [param spell], calculate its min, avg, and max damage values.
func calc_dmg_stats(spell: Spell) -> void:
	var min_dmg: float = spell.base
	var avg_dmg: float = spell.base
	var max_dmg: float = spell.base

	if spell.rank_combo == Spell.RankCombo.SET:
		min_dmg += LOW_CARD * spell.card_amt
		avg_dmg += ((LOW_CARD + HIGH_CARD) / 2.0) * spell.card_amt
		max_dmg += HIGH_CARD * spell.card_amt

	elif spell.rank_combo == Spell.RankCombo.RUN:
		min_dmg += (LOW_CARD + 1) * spell.card_amt

		var run_avg = func() -> float:
			var val: float = 0
			# Calculates main run hands (ie 2 3 4 to 9 10 11)
			for i in range(HIGH_CARD - LOW_CARD - 1):
				for j in range(spell.card_amt):
					val += LOW_CARD + i + j
			
			# Calculates bridging run (ie 11 2 3)
			val += HIGH_CARD
			for j in range(spell.card_amt - 1):
				val += LOW_CARD + j

			# 9 ways to make a run, avg value of run
			return val / (HIGH_CARD - LOW_CARD)

		avg_dmg += run_avg.call()
		max_dmg += (HIGH_CARD - 1) * spell.card_amt

	min_dmg *= spell.multi
	avg_dmg *= spell.multi
	max_dmg *= spell.multi

	print("min damage: ", min_dmg)
	print("avg damage: ", avg_dmg)
	print("max damage: ", max_dmg)


## Returns a [Dictionary] with the amount of each rank in [param hand].
func gather_ranks(hand: Array[Card]) -> Dictionary:
	var ranks: Dictionary = {}

	for card in hand:
		if card.rank not in ranks.keys():
			ranks[card.rank] = 1
		else:
			ranks[card.rank] += 1

	return ranks


## Returns a [Dictionary] with the amount of each [member Card.element] in [param hand].
func gather_elems(hand: Array[Card]) -> Dictionary:
	var elems: Dictionary = {}

	for card in hand:
		if card.element not in elems.keys():
			elems[card.element] = 1
		else:
			elems[card.element] += 1

	return elems


## Simulates hands and prints the probability the drawn hand matches the given [param spell].
func sample_probabilities(spell: Spell) -> void:
	var result = 0
	var samples = 10000
	for i in range(samples):
		deck.shuffle()
		var hand: Array[Card] = [deck[0], deck[1], deck[2], deck[3], deck[4], deck[5], deck[6]]
		if has_valid_spell(spell, hand):
			result += 1

	print("%d (%0.2f%%)" % [result, float(result) / samples * 100])


## Returns [code]true[/code] if the given hand has cards within that can be used to cast the
## [param spell].
func has_valid_spell(spell: Spell, hand: Array[Card]) -> bool:
	sort_cards(hand, true)

	match spell.rank_combo:
		Spell.RankCombo.SET: 
			if not has_valid_set(hand, spell.card_amt):
				return false

		Spell.RankCombo.RUN: 
			if not has_valid_run(hand, spell.card_amt, spell.elem_combo):
				return false

	return true


## Returns [code][true][/code] if [Card] objects in [param hand] is able to make a set
## of [param card_amt].
func has_valid_set(hand: Array[Card], card_amt: int) -> bool:
	for num in gather_ranks(hand).values():
		if num >= card_amt:
			#print("true: ", hand)
			return true
	
	#print("false: ", hand)
	return false


## Returns [code][true][/code] if [Card] objects in [param hand] is able to make a run
## of [param card_amt].
func has_valid_run(hand: Array[Card], card_amt: int, elem_combo: Spell.ElemCombo) -> bool:
	for i in range(hand.size()):
		var run = 1
		var last = hand[i].rank

		for j in range(i+1, hand.size()):
			if hand[j].rank == last + 1:
				if not check_elem_combo(elem_combo, hand[i], hand[j]):
					continue

				run += 1
				last = hand[j].rank

				if run >= card_amt:
					#print("true: ", hand)
					return true

		# Check for W card bridge (W 2 3)
		if hand[i].rank == 11:
			run = 1
			last = 11

			for j in range(hand.size()):
				if hand[j].rank == last + 1 or (last == 11 and hand[j].rank == 2):
					if not check_elem_combo(elem_combo, hand[i], hand[j]):
						continue

					run += 1
					last = hand[j].rank

					if run >= card_amt:
						#print("true: ", hand)
						return true

	#print("false: ", hand)
	return false


## Sorts [member Player.hand] by [member Card.rank] if [param by_rank] is [code]true[/code].
## Otherwise, it sorts it by [member Card.element]. Modifies the existing [Array].
static func sort_cards(cards: Array[Card], by_rank: bool) -> void:
	var asc_value := func (a: Card, b: Card) -> int:
		if by_rank:
			return a.rank < b.rank
		else:
			return a.element < b.element

	cards.sort_custom(asc_value)


## Returns the first [Spell] that can be case from the given [param hand].
static func get_valid_spell(spells: Array[Spell], hand: Array[Card]) -> Spell:
	for spell in spells:
		if is_valid_spell(spell, hand):
			return spell
	
	return null


## Returns [code]true[/code] if given [param hand] works for [param spell].
static func is_valid_spell(spell: Spell, hand: Array[Card]) -> bool:
	if hand.size() != spell.card_amt:
		return false

	sort_cards(hand, true)

	match spell.rank_combo:
		Spell.RankCombo.SET: 
			if not is_valid_set(hand, spell.elem_combo):
				return false

		Spell.RankCombo.RUN: 
			if not is_valid_run(hand, spell.elem_combo):
				return false

	return true


## Returns [code][true][/code] if every [Card] in [param hand] have the same
## [member Card.rank].
static func is_valid_set(hand: Array[Card], elem_combo: Spell.ElemCombo) -> bool:
	for i in range(hand.size() - 1):
		if hand[i].rank != hand[i + 1].rank:
			return false

		if not check_elem_combo(elem_combo, hand[i], hand[i + 1]):
			return false
	
	return true


## Returns [code][true][/code] if every [Card] in [param hand] are in ascending
## [member Card.rank].
static func is_valid_run(hand: Array[Card], elem_combo: Spell.ElemCombo) -> bool:
	for i in range(hand.size() - 1):
		if hand[i].rank != (hand[i + 1].rank - 1):
			# Checks for W card bridge (W 2 3)
			if i == hand.size() - 2 and hand[0].rank == 2 and hand[i + 1].rank == 11:
				if (not check_elem_combo(elem_combo, hand[i], hand[0]) or 
					not check_elem_combo(elem_combo, hand[i + 1], hand[0])):
					return false
				return true
			return false

		if not check_elem_combo(elem_combo, hand[i], hand[i + 1]):
			return false
	
	return true


## Returns [code][true][/code] if [param card1] and [param card2] are matching the 
## element [param combo].
static func check_elem_combo(combo: Spell.ElemCombo, card1: Card, card2: Card) -> bool:
	match combo:
		Spell.ElemCombo.ANY:
			return true

		Spell.ElemCombo.MATCH_ANY:
			return card1.element == card2.element

		_:
			return false