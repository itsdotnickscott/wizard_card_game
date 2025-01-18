class_name Analysis extends Resource


var spellbook: Array
var deck: Array[Card]


## =====  CONSTRUCTOR  ===== ##


func _init(spells: Array, cards: Array[Card]) -> void:
	spellbook = spells
	deck = cards


## =====  NON STATIC FUNCTIONS  =====  ##


## Prints out details of each [Spell] in [Analysis.spellbook] into the console.
func analyze_spells(hand_size: int) -> void:
	for spell in spellbook:
		print(get_spell_info(spell) + "\n")
		sample_probabilities(spell, hand_size)
		print("\n* -------------------------------------------------------------------- *\n")


## Simulates hands and prints the probability the drawn hand matches the given [param spell].
func sample_probabilities(spell: Spell, hand_size: int) -> void:
	var result := 0

	var min_dmg := INF
	var max_dmg := 0.0
	var tot_dmg := 0.0

	var best_hand := []

	var samples := 1000
	
	for i in range(samples):
		deck.shuffle()
		var hand: Array[Card] = []
		for j in range(hand_size):
			hand.append(deck[j])

		if is_valid_spell(spell, hand, false):
			result += 1
			var cards = get_hand_from_spell(spell, hand)
			var dmg = calc_dmg(cards, spell)

			if dmg < min_dmg:
				min_dmg = dmg
			if dmg > max_dmg:
				max_dmg = dmg
				best_hand = cards

			tot_dmg += dmg

	print("%d (%0.2f%%)" % [result, float(result) / samples * 100])
	print("\tBest Hand: ", best_hand)
	print("\tMin Dmg: ", min_dmg)
	print("\tAvg Dmg: %0.2f" % [tot_dmg / result])
	print("\tMax Dmg: ", max_dmg)
	print("\tExpected Value: %0.2f" % [tot_dmg / samples])
	

## =====  STATIC FUNCTIONS ===== ##


## Given an [Array] of [Card] objects, calculate its damage value when cast with [param spell].
## This function assumes all the cards in [param hand] will be scored.
static func calc_dmg(
	hand: Array[Card], spell: Spell, effects: Array[Effect] = [], show: bool = false
) -> float:
	var base: int = spell.base
	var multi: float = spell.multi

	for card in hand:
		base += card.rank

	for effect in effects:
		if effect is Effect.AddDamage:
			var valid := false

			if effect.condition == Effect.Condition.CONTAINS_PAIR:
				if has_pair(hand):
					valid = true

			elif (
				effect.condition == Effect.Condition.CONTAINS_SET or 
				effect.condition == Effect.Condition.CONTAINS_RUN
			):
				if is_valid_spell(Spell.get_spell_from_meld(effect.condition), hand, false):
					valid = true

			elif effect.condition == Effect.Condition.NONE:
				valid = true

			if valid:
				print(effect.name)
				if effect.multi:
					multi += effect.add
				else:
					base += effect.add

	var dmg = base * multi

	if show:
		print("[ %d x %0.2f ]" % [base, multi])

	return dmg


## Sorts [member Player.hand] by [member Card.rank] if [param by_rank] is [code]true[/code].
## Otherwise, it sorts it by [member Card.affinity]. Modifies the existing [Array].
static func sort_cards(cards: Array[Card], by_rank: bool) -> void:
	var asc_rank := func(a: Card, b: Card) -> int:
		if a.type == Card.Type.DRAGON and b.type == Card.Type.DRAGON:
			return a.affinity < b.affinity
		else:
			if a.type == Card.Type.WIND and b.type == Card.Type.WIND:
				return a.wind < b.wind
			else:
				return a.rank < b.rank

	var asc_aff := func(a: Card, b: Card) -> int:
		return a.affinity < b.affinity

	cards.sort_custom(asc_rank)

	if not by_rank:
		cards.sort_custom(asc_aff)
	

## Prints various important info of a [param spell] onto the console.
static func get_spell_info(spell: Spell) -> String:
	var subtitle := ""

	for i in range(spell.parts()):
		subtitle += str(spell.quantity[i]) + "x "

		match spell.melds[i]:
			Spell.Meld.HIGH_CARD:
				subtitle += "HIGH CARD"
			Spell.Meld.PAIR:
				subtitle += "PAIR"
			Spell.Meld.RUN:
				subtitle += "RUN"
			Spell.Meld.SET:
				subtitle += "SET"

		subtitle += " | " if i == spell.parts() - 1 else " + "

	subtitle += "%d x %0.2f" % [spell.base, spell.multi]

	return spell.name + " | " + subtitle


## =====  SPELL VERIFICATION FUNCTIONS  ===== ##


## Returns the first [Spell] that can be case from the given [param hand].
## If [param exact] is [code]true[/code], then the [param hand] must match the spell exactly.
static func get_valid_spell(spells: Array[Spell], hand: Array[Card], exact: bool) -> Spell:
	var valid := []
	for spell in spells:
		if is_valid_spell(spell, hand, exact):
			valid.append(spell)
	
	if valid.is_empty():
		return null
	elif valid.size() > 1:
		var best: Spell = valid[0]
		var high: float = calc_dmg(get_hand_from_spell(valid[0], hand), valid[0])

		for spell in valid.slice(1):
			var scoring_hand := get_hand_from_spell(spell, hand)
			var dmg := calc_dmg(scoring_hand, spell)

			if dmg > high:
				best = spell
				high = dmg

		return best
	else:
		return valid[0]


## Returns an [Array] of [Card] objects that are used to make up the composition of a [Spell].
static func get_hand_from_spell(spell: Spell, hand: Array[Card]) -> Array[Card]:
	sort_cards(hand, true)

	var combos := []

	for i in range(spell.parts()):
		var part := []
		match spell.melds[i]:
			Spell.Meld.HIGH_CARD:
				for card in hand:
					part.append([card])

			Spell.Meld.PAIR:
				part = _get_valid_pairs(hand, spell, i)
				
			Spell.Meld.SET:
				part = _get_valid_sets(hand, spell, i)

			Spell.Meld.RUN:
				part = _get_valid_runs(hand, spell, i)

		combos.append(part)

	return _untyped_arr_to_card_arr(_get_unique_valid_hand(spell, combos))


## Returns [code]true[/code] if given [param hand] works for [param spell].
## If [param exact] is [code]true[/code], then the [param hand] must match the spell exactly.
static func is_valid_spell(spell: Spell, hand: Array[Card], exact: bool) -> bool:
	if exact and hand.size() != spell.size():
		return false

	sort_cards(hand, true)

	var combos := []

	for i in range(spell.parts()):
		var part := []
		match spell.melds[i]:
			Spell.Meld.HIGH_CARD:
				for card in hand:
					part.append([card])

			Spell.Meld.PAIR:
				part = _get_valid_pairs(hand, spell, i)
				
			Spell.Meld.SET:
				part = _get_valid_sets(hand, spell, i)

			Spell.Meld.RUN:
				part = _get_valid_runs(hand, spell, i)

		if part.size() < spell.quantity[i]:
			return false

		combos.append(part)

	if _get_unique_valid_hand(spell, combos).is_empty():
		return false

	return true


static func has_pair(hand: Array[Card]) -> bool:
	var matches := []

	for card in hand:
		var found := false

		for m in matches:
			if card.rank == Card.WIND_RANK and m[0].wind != card.wind:
				continue

			if m[0].rank == card.rank and m[0].affinity == card.affinity:
				m.append(card)
				found = true
				continue

		if not found:
			matches.append([card])

	for m in matches:
		if m.size() == 2:
			return true

	return false


## =====  HELPER FUNCTIONS  ===== ##


static func _sort_cards_into_arrays(by_rank: bool, by_aff: bool, cards: Array[Card]) -> Array[Array]:
	var sorted: Array[Array] = []

	# Sort all cards by rank / wind
	for card in cards:
		var found := false

		for arr in sorted:
			if by_rank:
				if card.rank == Card.WIND_RANK and arr[0].wind != card.wind:
					continue

				if arr[0].rank == card.rank:
					if by_aff and card.affinity != arr[0].affinity:
						continue
					arr.append(card)
					found = true
					break

			elif by_aff:
				if card.affinity == arr[0].affinity:
					arr.append(card)
					found = true
					break

		if not found:
			sorted.append([card])
	
	return sorted


## Returns all valid pairs that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
static func _get_valid_pairs(hand: Array[Card], spell: Spell, part: int) -> Array[Array]:
	var matches := _sort_cards_into_arrays(true, true, hand)
	var sets := []

	for arr in matches:
		if arr.size() >= spell.get_meld_size(part):
			sets.append(arr)

	return _filter_combos_to_size(sets, spell.get_meld_size(part))


## Returns all valid runs that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
## Runs have additional checkers for Affinity Combos, Face Cards, and Wild Affinities.[br]
## Note: [param hand] must be sorted by rank before using this function.
static func _get_valid_runs(hand: Array[Card], spell: Spell, part: int) -> Array[Array]:
	var matches := _sort_cards_into_arrays(true, true, hand)
	var runs := []

	var find_next_idx := func(match: bool, i: int, affs: Array[Card.Affinity] = []) -> int:
		var travel := 1
		for arr in matches.slice(i + 1):
			# Card is next in sequence
			if arr[0].rank == matches[i][0].rank + 1:
				if (match and arr[0].affinity == hand[i].affinity) or \
				(not match and not arr[0].affinity in affs):
					return i + travel
			travel += 1
		return -1
	
	var idx = 0
	for arr in matches:
		# When t is 0 it searches for matching runs and when t is 1 it searches for unique runs
		for t in range(2):
			var run := [arr[0]]
			var affs: Array[Card.Affinity] = [arr[0].affinity]
			var next = find_next_idx.call(true, idx) if t == 0 \
				else find_next_idx.call(false, idx, affs)

			while next != -1:
				run.append(matches[next][0])

				if t == 0:
					next = find_next_idx.call(true, next)
				else:
					affs.append(matches[next][0].affinity)
					next = find_next_idx.call(false, next, affs)

			if run.size() >= spell.get_meld_size(part):
				runs.append(run)

		idx += 1

	return _filter_combos_to_size(runs, spell.get_meld_size(part))
	

## Returns all valid sets that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
static func _get_valid_sets(hand: Array[Card], spell: Spell, part: int) -> Array[Array]:
	var by_rank := _sort_cards_into_arrays(true, false, hand)
	var sets := []

	# Find matching sets eith either all matching or all unique affinities
	for rank in by_rank:
		var by_aff := _sort_cards_into_arrays(false, true, _untyped_arr_to_card_arr(rank))

		# Only one affinity
		if by_aff.size() == 1:
			# Check for enough cards
			if by_aff[0].size() >= spell.get_meld_size(part):
				sets.append(by_aff[0]) 
		
		# Enough unique affinities
		while by_aff.size() >= spell.get_meld_size(part):
			# Take a card from each affinity
			var cards := []
			for i in range(by_aff.size()):
				cards.append(by_aff[i].pop_front())
			sets.append(cards)

			# Remove any empty arrays
			var non_empty := func(x: Array) -> bool:
				return not x.is_empty()
			by_aff = by_aff.filter(non_empty)

	return _filter_combos_to_size(sets, spell.get_meld_size(part))


static func _filter_combos_to_size(combos: Array, size: int) -> Array[Array]:
	var hands: Array[Array] = []
	for arr in combos:
		hands += _get_set_combinations(arr, size)

	return hands


## This function recursively combines all valid combinations through each spell part. It checks
## to make sure that each combo is unique from each other.[br]
## i.e. for a full house, we check all valid three-of-a-kinds with all valid pairs
## And pairs have valid combos that include the cards used from the part before which we
## don't want to include.
static func _build_valid_hands(combos: Array, spell: Spell, part:=0, hand:=[]) -> Array[Array]:
	# Base case: if we've reached the last part then we've constructed a unique hand
	if part == combos.size():
		return [hand]

	var hands: Array[Array] = []

	for small_hand in combos[part]:
		var unique := true

		for card in small_hand:
			if card in hand:
				unique = false
				break

		if unique:
			var finished_hand = _build_valid_hands(combos, spell, part + 1, hand + small_hand)
			# Recursive case: if a card is unique it shows up as an empty array
			if not finished_hand.is_empty():
				hands += finished_hand

	# Recursive case: return any finished hands we completed
	return hands


## Returns all of the possible combinations that could be made with the cards, but order matters.
## Effectively, if [param cards] has more cards than [param size], it will create different
## combinations of them.[br]
## Note: Assumes [param cards] is already a valid run.
static func _get_run_combinations(cards: Array, size: int) -> Array[Array]:
	var combinations: Array[Array] = []

	if cards[0].rank == Card.MIN_RANK and cards[-1].rank == Card.BRIDGE_RANK:
		cards.push_front(cards.pop_back())

	for i in range(cards.size() - size + 1):
		var smaller_combination := []
		for j in range(size):
			smaller_combination.append(cards[j + i])

		combinations.append(smaller_combination)

	return combinations


## Returns all of the possible combinations that could be made with the cards, order doesn't matter.
## Effectively, if [param cards] has more cards than [param size], it will create different
## combinations of them.[br]
## Note: Assumes [param cards] is already a valid set.
static func _get_set_combinations(cards: Array, size: int) -> Array[Array]:
	# Base cases
	if size <= 0:
		return [[]] # Return a 2D array with an empty combination
	if size > cards.size():
		return [] # No combinations possible

	# Recursive step: take one card and find combinations of the rest
	var combinations: Array[Array] = []

	for i in range(cards.size()):
		var card = cards[i]
		var remaining_cards := cards.slice(i + 1) # Take cards after the current one
		var smaller_combinations := _get_set_combinations(remaining_cards, size - 1)

		for combination in smaller_combinations:
			combinations.append([card] + combination)

	return combinations
			

## Given [param combos], an [Array] of all possible sets, runs, or match anys based on the
## [param spell], return the best scoring hand.
static func _get_unique_valid_hand(spell: Spell, combos: Array) -> Array[Card]:
	var combinations := []

	for i in range(spell.parts()):
		combinations.append(_get_valid_combinations(spell, i, combos[i]))

	var hands := _build_valid_hands(combinations, spell)

	if hands.is_empty():
		return []

	elif hands.size() > 1:
		var best: Array = hands[0]
		var high: float = calc_dmg(_untyped_arr_to_card_arr(hands[0]), spell)

		for hand in hands.slice(1):
			var dmg = calc_dmg(_untyped_arr_to_card_arr(hand), spell)

			if dmg > high:
				best = hand
				high = dmg

		return _untyped_arr_to_card_arr(best)

	else:
		return _untyped_arr_to_card_arr(hands[0])


static func _untyped_arr_to_card_arr(arr: Array) -> Array[Card]:
	var hand: Array[Card] = []
	hand.assign(arr)
	return hand


## Returns an [Array] of valid hands that could be made from the current part.
## "Valid" means that it has the proper quantity of unique [Card] objects.
static func _get_valid_combinations(spell: Spell, part: int, hands: Array) -> Array[Array]:
	var combos := _get_set_combinations(hands, spell.quantity[part])
	var valid: Array[Array] = []

	# A combo represents ways to make up one part of the spell given the hand
	# ie. a 2-pair could represent [[Card(2,0), Card(2,1)], [Card(3,0), Card(3,1)]]
	for combo in combos:
		var used := []
		var sets := []

		# A small hand represents one part of the combo ie. [Card(2,0), Card(2,1)]
		for small_hand in combo:
			var unique := true

			# Check every card and make sure it is unique
			for card in small_hand:
				if card in used:
					unique = false
					break
				if spell.melds[part] == Spell.Meld.SET and card.rank in sets:
					unique = false
					break
				used.append(card)

			if not unique:
				break

			if spell.melds[part] == Spell.Meld.SET:
				sets.append(small_hand[0].rank)
		
		# If used has every unique card needed to cast then add to valid combinations
		if used.size() == spell.get_meld_size(part) * spell.quantity[part]:
			valid.append(used)
	return valid