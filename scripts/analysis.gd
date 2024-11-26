class_name Analysis extends Resource


const LOW_CARD = 2
const HIGH_CARD = 11
const HAND_SIZE = 7


var spellbook: Array[Spell]
var deck: Array[Card]


## =====  CONSTRUCTOR  ===== ##


func _init(spells: Array[Spell], cards: Array[Card]) -> void:
	spellbook = spells
	deck = cards


## =====  NON STATIC FUNCTIONS  =====  ##


## Prints out details of each [Spell] in [Analysis.spellbook] into the console.
func analyze_spells() -> void:
	for spell in spellbook:
		print("\n* -------------------------------------------------------------------- *\n")
		print(get_spell_info(spell) + "\n")
		sample_probabilities(spell)
		
		


## Simulates hands and prints the probability the drawn hand matches the given [param spell].
func sample_probabilities(spell: Spell) -> void:
	var result := 0

	var min_dmg := INF
	var max_dmg := 0.0
	var tot_dmg := 0.0

	var best_hand := []

	var samples := 2000
	
	for i in range(samples):
		deck.shuffle()
		var hand: Array[Card] = []
		for j in range(HAND_SIZE):
			hand.append(deck[j])

		if is_valid_spell(spell, hand, false):
			result += 1
			var cards = get_hand_from_spell(spell, hand)
			var dmg = calc_dmg(cards, spell)

			if dmg < min_dmg:
				min_dmg = dmg
			elif dmg > max_dmg:
				max_dmg = dmg
				best_hand = cards

			tot_dmg += dmg

	print("%d (%0.2f%%)" % [result, float(result) / samples * 100])
	print("\tBest Hand: ", best_hand)
	print("\tMin Dmg: ", min_dmg)
	print("\tAvg Dmg/Cast: %0.2f" % [tot_dmg / result])
	print("\tMax Dmg: ", max_dmg)
	print("\tExpected Value: %0.2f" % [tot_dmg / samples])
	


## =====  STATIC FUNCTIONS ===== ##


## Given an [Array] of [Card] objects,  calculate its
## damage value when cast with [param spell].
static func calc_dmg(hand: Array, spell: Spell) -> float:
	var base: int = spell.base

	for card in hand:
		base += card.rank

	var dmg = base * spell.multi

	return dmg


## Sorts [member Player.hand] by [member Card.rank] if [param by_rank] is [code]true[/code].
## Otherwise, it sorts it by [member Card.element]. Modifies the existing [Array].
static func sort_cards(cards: Array[Card], by_rank: bool) -> void:
	var asc_value := func(a: Card, b: Card) -> int:
		if by_rank:
			return a.rank < b.rank
		else:
			return a.element < b.element

	cards.sort_custom(asc_value)


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


## =====  SPELL VERIFICATION FUNCTIONS  ===== ##


## Returns the first [Spell] that can be case from the given [param hand].
static func get_valid_spell(spells: Array[Spell], hand: Array[Card], exact: bool) -> Spell:
	for spell in spells:
		if is_valid_spell(spell, hand, exact):
			return spell
	
	return null


## Returns [code]true[/code] if given [param hand] works for [param spell].
static func is_valid_spell(spell: Spell, hand: Array[Card], exact: bool) -> bool:
	if exact and hand.size() != spell.size():
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

		if part.size() < spell.quantity[i]:
			return false

		combos.append(part)

	if get_unique_valid_hand(spell, combos).is_empty():
		return false

	return true


## Assumes hand is already
static func get_hand_from_spell(spell: Spell, hand: Array[Card]) -> Array:
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

	return get_unique_valid_hand(spell, combos)
			

static func get_unique_valid_hand(spell: Spell, combos: Array) -> Array:
	var combinations := []

	for i in range(spell.parts()):
		combinations.append(get_valid_combinations(spell, i, combos[i]))

	var hands := build_valid_hands(combinations)

	if hands.is_empty():
		return []

	elif hands.size() > 1:
		var best: Array = hands[0]
		var high: float = calc_dmg(hands[0], spell)

		for hand in hands.slice(1):
			var dmg = calc_dmg(hand, spell)

			if dmg > high:
				best = hand
				high = dmg

		return best

	else:
		return hands[0]


## Returns an [Array] of valid hands that could be made from the current part.
static func get_valid_combinations(spell: Spell, part: int, hands: Array) -> Array:
	var combos := _get_set_combinations(hands, spell.quantity[part])
	var valid := []

	# A combo represents ways to make up one part of the spell given the hand
	# ie. a 2-pair could represent [[Card(2,0), Card(2,1)], [Card(3,0), Card(3,1)]]
	for combo in combos:
		var used := []

		# A small hand represents one part of the combo ie. [Card(2,0), Card(2,1)]
		for small_hand in combo:
			var unique := true

			# Check every card and make sure it is unique
			for card in small_hand:
				if card in used:
					unique = false
					break
				used.append(card)

			if not unique:
				break
		
		# If used has every unique card needed to cast then add to valid combinations
		if used.size() == spell.card_amt[part] * spell.quantity[part]:
			valid.append(used)
	return valid


static func build_valid_hands(combos: Array, part: int=0, hand: Array=[]) -> Array:
	# Base case: if we've reached the last part then we've constructed a unique hand
	if part == combos.size():
		return [hand]

	var hands := []

	for small_hand in combos[part]:
		var unique := true

		for card in small_hand:
			if card in hand:
				unique = false
				break

		if unique:
			var finished_hand = build_valid_hands(combos, part + 1, hand + small_hand)
			# Recursive case: if a card is unique it shows up as an empty array
			if not finished_hand.is_empty():
				hands += finished_hand

	# Recursive case: return any finished hands we completed
	return hands


## =====  SPELL-SPECIFIC VERIFIERS  ===== ##


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
					if _check_elem_combo(spell.elem_combo[part], r[-1], card):
						r.append(card)
						added = true
						break

			if not added:
				# Check if W and 2 can be bridged first
				if card.rank == 11:
					for r in runs:
						if r[0].rank == 2:
							if _check_elem_combo(spell.elem_combo[part], r[-1], card):
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


## =====  HELPER FUNCTIONS  ===== ##


## Returns [code][true][/code] if [param card1] and [param card2] are matching the 
## element [param combo].
static func _check_elem_combo(combo: Spell.ElemCombo, card1: Card, card2: Card) -> bool:
	match combo:
		Spell.ElemCombo.ANY:
			return true

		Spell.ElemCombo.MATCH_ANY:
			return card1.element == card2.element

		_:
			return false


## Returns a [Dictionary] with the amount of each rank in [param hand].
static func _count_ranks(hand: Array[Card]) -> Dictionary:
	var ranks: Dictionary = {}

	for card in hand:
		if card.rank not in ranks.keys():
			ranks[card.rank] = 1
		else:
			ranks[card.rank] += 1

	return ranks


## Returns a [Dictionary] with the amount of each [member Card.element] in [param hand].
static func _count_elems(hand: Array[Card]) -> Dictionary:
	var elems: Dictionary = {}

	for card in hand:
		if card.element not in elems.keys():
			elems[card.element] = 1
		else:
			elems[card.element] += 1

	return elems


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
		return [[]] # Return a 2D array with an empty combination
	if size > cards.size():
		return [] # No combinations possible

	# Recursive step: take one card and find combinations of the rest
	var combinations := []

	for i in range(cards.size()):
		var card = cards[i]
		var remaining_cards := cards.slice(i + 1) # Take cards after the current one
		var smaller_combinations := _get_set_combinations(remaining_cards, size - 1)

		for combination in smaller_combinations:
			combinations.append([card] + combination)

	return combinations
