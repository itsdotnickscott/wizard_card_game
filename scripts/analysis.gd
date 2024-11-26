class_name Analysis extends Resource


const LOW_CARD = 2
const HIGH_CARD = 11
const HAND_SIZE = 7


var spellbook: Array[Spell]
var deck: Array[Card]


func _init(spells: Array[Spell], cards: Array[Card]) -> void:
	spellbook = spells
	deck = cards


## Prints out details of each spell into the console.
func analyze_spells() -> void:
	for spell in spellbook:
		print(get_spell_info(spell))
		calc_dmg_stats(spell)
		sample_probabilities(spell)
		print()


## Prints the title and hand composition of a [param spell] onto the console.
static func get_spell_info(spell: Spell) -> String:
	var subtitle := ""

	for i in range(spell.parts()):
		subtitle += str(spell.quantity[i]) + "x "

		match spell.rank_combo[i]:
			Spell.RankCombo.SET:
				subtitle += "SET"
			Spell.RankCombo.RUN:
				subtitle += "RUN"
			Spell.RankCombo.ANY:
				subtitle += "ANY"	

		subtitle += " of %d, " % [spell.card_amt[i]]

		match spell.elem_combo[i]:
			Spell.ElemCombo.ANY:
				subtitle += "ANY"
			Spell.ElemCombo.MATCH_ANY:
				subtitle += "MATCH ANY"

		subtitle += " | "

	subtitle += "[%d x %0.2f]" % [spell.base, spell.multi]

	return spell.name + " | " + subtitle


## Given a [param spell], calculate its min, avg, and max damage values.
func calc_dmg_stats(spell: Spell) -> void:
	var min_dmg: float = spell.base
	var avg_dmg: float = spell.base
	var max_dmg: float = spell.base

	for i in range(spell.parts()):
		match spell.rank_combo[i]:
			Spell.RankCombo.SET, Spell.RankCombo.ANY:
				for j in range(spell.quantity[i]):
					min_dmg += (LOW_CARD + j) * spell.card_amt[i] 
					avg_dmg += ((LOW_CARD + HIGH_CARD) / 2.0) * spell.card_amt[i]
					max_dmg += (HIGH_CARD - j) * spell.card_amt[i]

			Spell.RankCombo.RUN:
				min_dmg += (LOW_CARD + 1) * spell.card_amt[i] * spell.quantity[i]

				var run_avg = func() -> float:
					var val: float = 0
					# Calculates main run hands (ie 2 3 4 to 9 10 11)
					for j in range(HIGH_CARD - LOW_CARD - 1):
						for k in range(spell.card_amt[i]):
							val += LOW_CARD + i + j
					
					# Calculates bridging run (ie 11 2 3)
					val += HIGH_CARD
					for j in range(spell.card_amt[i] - 1):
						val += LOW_CARD + j

					# 9 ways to make a run, avg value of run
					return val / (HIGH_CARD - LOW_CARD) * spell.quantity[i]

				avg_dmg += run_avg.call()
				max_dmg += (HIGH_CARD - 1) * spell.card_amt[i] * spell.quantity[i]

	min_dmg *= spell.multi
	avg_dmg *= spell.multi
	max_dmg *= spell.multi

	print("min damage: ", min_dmg)
	print("avg damage: ", avg_dmg)
	print("max damage: ", max_dmg)


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


## Returns a [Dictionary] with the amount of each rank in [param hand].
static func count_ranks(hand: Array[Card]) -> Dictionary:
	var ranks: Dictionary = {}

	for card in hand:
		if card.rank not in ranks.keys():
			ranks[card.rank] = 1
		else:
			ranks[card.rank] += 1

	return ranks


## Returns a [Dictionary] with the amount of each [member Card.element] in [param hand].
static func count_elems(hand: Array[Card]) -> Dictionary:
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
	var samples = 1000
	
	for i in range(samples):
		deck.shuffle()
		var hand: Array[Card] = []
		for j in range(HAND_SIZE):
			hand.append(deck[j])

		if has_valid_spell(spell, hand):
			result += 1

	print("%d (%0.2f%%)" % [result, float(result) / samples * 100])


## Returns [code]true[/code] if the given hand has cards within that can be used to cast the
## [param spell].
func has_valid_spell(spell: Spell, hand: Array[Card]) -> bool:
	sort_cards(hand, true)

	for i in range(spell.parts()):
		if not has_valid_hand(hand, spell, i):
			return false

	return true


## Returns [code][true][/code] if [Card] objects in [param hand] is able to make a set
## of [param card_amt].
func has_valid_hand(hand: Array[Card], spell: Spell, part: int) -> bool:
	var combos := []
	match spell.rank_combo[part]:
		Spell.RankCombo.SET: 
			combos = get_valid_sets(hand, spell, part)

		Spell.RankCombo.RUN: 
			combos = get_valid_runs(hand, spell, part)

		Spell.RankCombo.ANY when spell.elem_combo[part] == Spell.ElemCombo.MATCH_ANY: 
			combos = get_valid_match_anys(hand, spell, part)

	var count := 0
	var used := []

	combos.reverse()
	for combo in combos:
		var new := true
		for card in used:
			if card in combo:
				new = false

		if new:
			count += 1
			used += combo

			if count == spell.quantity[part]:
				return true
	return false


static func get_valid_sets(hand: Array[Card], spell: Spell, part: int) -> Array:
	var by_rank := {}
	for card in hand:
		if by_rank.has(card.rank):
			by_rank[card.rank].append(card)
		else:
			by_rank[card.rank] = [card]

	var sets := []
	for cards in by_rank.values():
		if cards.size() >= spell.card_amt[part]:
			sets.append(cards)

	var hands := []
	for s in sets:
		hands += _get_set_combinations(s, spell.card_amt[part])

	#print(hands)
	return hands


static func get_valid_runs(hand: Array[Card], spell: Spell, part: int) -> Array:
	var runs := []
	for card in hand:
		if runs.size() == 0:
			runs.append([card])

		else:
			var added := false
			for r in runs:
				# Last card of run is 1 below current card
				if card.rank == r[-1].rank + 1:
					if check_elem_combo(spell.elem_combo[part], r[-1], card):
						r.append(card)
						added = true
						break

			if not added:
				# Check if W and 2 can be bridged first
				if card.rank == 11:
					for r in runs:
						if r[0].rank == 2:
							if check_elem_combo(spell.elem_combo[part], r[-1], card):
								r.append(card)
								break
						elif r[0].rank > 2:
							break
				else:
					runs.append([card])

	var hands := []
	for r in runs:
		if r.size() > spell.card_amt[part]:
			hands += _get_run_combinations(r, spell.card_amt[part])
		elif r.size() == spell.card_amt[part]:
			hands.append(r)

	#print(hands)
	return hands


static func get_valid_match_anys(hand: Array[Card], spell: Spell, part: int) -> Array:
	var by_elem := {}
	for card in hand:
		if by_elem.has(card.element):
			by_elem[card.element].append(card)
		else:
			by_elem[card.element] = [card]
			
	var sets := []
	for cards in by_elem.values():
		if cards.size() >= spell.card_amt[part]:
			sets.append(cards)

	var hands := []
	for s in sets:
		hands += _get_set_combinations(s, spell.card_amt[part])

	#print(hands)
	return hands


static func _get_run_combinations(cards: Array, size: int) -> Array:
	var combinations := []

	if cards[0].rank == 2 and cards[-1].rank == 11:
		cards.push_front(cards.pop_back())

	for i in range(cards.size() - size + 1):
		var smaller_combination := []
		for j in range(size):
			smaller_combination.append(cards[j + i])

		combinations.append(smaller_combination)

	return combinations


static func _get_set_combinations(cards: Array, size: int) -> Array:
	# Base cases
	if size == 0:
		return [[]]  # Return a 2D array with an empty combination
	if size > cards.size():
		return []  # No combinations possible

    # Recursive step: take one card and find combinations of the rest
	var combinations := []

	for i in range(cards.size()):
		var card: Card = cards[i]
		var remaining_cards := cards.slice(i + 1)  # Take cards after the current one
		var smaller_combinations := _get_set_combinations(remaining_cards, size - 1)

		for combination in smaller_combinations:
			combinations.append([card] + combination)

	return combinations


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
	if hand.size() != spell.size():
		return false

	sort_cards(hand, true)

	var combos := []
	for i in range(spell.parts()):
		var part := []
		match spell.rank_combo[i]:
			Spell.RankCombo.SET: 
				part = get_valid_sets(hand, spell, i)

			Spell.RankCombo.RUN: 
				part = get_valid_runs(hand, spell, i)

			Spell.RankCombo.ANY when spell.elem_combo[i] == Spell.ElemCombo.MATCH_ANY: 
				part = get_valid_match_anys(hand, spell, i)

		combos.append(part)
	
	if get_unique_valid_hand(spell, combos).is_empty():
		return false

	return true


static func get_unique_valid_hand(spell: Spell, combos: Array) -> Array:
	var combinations := []
	# A part represents ways to make up one part of the spell given the hand
	# ie. a 2-pair could represent [[Card(2,0), Card(2,1)], [Card(3,0), Card(3,1)]]
	for part in combos:
		var used := []
		var unique := true

		# A small hand represents certain cards that make up the part in whole
		# ie. a 2-pair could have small hand [Card(2,0), Card(2,1)]
		for small_hand in part:
			for card in small_hand:
				if card in used:
					unique = false
					break
				used.append(card)

			if not unique:
				break

		if not unique:
			return []

		var result = []
		for small_hand in part:
			result += small_hand
		combinations.append(result)

	for combo in combinations:
		if combo.size() == spell.size():
			return combo

	return []
