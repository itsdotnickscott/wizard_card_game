class_name Analysis extends Resource


var spellbook: Array[Spell]
var deck: Array[Card]


## =====  CONSTRUCTOR  ===== ##


func _init(spells: Array[Spell], cards: Array[Card]) -> void:
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

		var TEST_WITH_EFFECTS : Array[Effect] = [
			#Effect.Wild.new(Card.Affinity.ARCANA, 1, -1)
		]

		if is_valid_spell(spell, hand, false, TEST_WITH_EFFECTS):
			result += 1
			var cards = _get_hand_from_spell(spell, hand, TEST_WITH_EFFECTS)
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
static func calc_dmg(hand: Array, spell: Spell) -> float:
	var base: int = spell.base

	for card in hand:
		base += card.rank

	var dmg = base * spell.multi

	return dmg


## Sorts [member Player.hand] by [member Card.rank] if [param by_rank] is [code]true[/code].
## Otherwise, it sorts it by [member Card.affinity]. Modifies the existing [Array].
static func sort_cards(cards: Array[Card], by_rank: bool) -> void:
	var asc_value := func(a: Card, b: Card) -> int:
		if not by_rank or (a.type == Card.Type.DRAGON and b.type == Card.Type.DRAGON):
			return a.affinity < b.affinity
		else:
			if a.type == Card.Type.WIND and b.type == Card.Type.WIND:
				return a.wind < b.wind
			else:
				return a.rank < b.rank

	cards.sort_custom(asc_value)


## Prints various important info of a [param spell] onto the console.
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

		match spell.aff_combo[i]:
			Spell.AffCombo.ANY:
				subtitle += "ANY"
			Spell.AffCombo.MATCH_ANY:
				subtitle += "MATCH ANY"

		subtitle += " | "

	subtitle += "[%d x %0.2f]" % [spell.base, spell.multi]

	return spell.name + " | " + subtitle


## =====  SPELL VERIFICATION FUNCTIONS  ===== ##


## Returns the first [Spell] that can be case from the given [param hand].
## If [param exact] is [code]true[/code], then the [param hand] must match the spell exactly.
static func get_valid_spell(
	spells: Array[Spell], hand: Array[Card], exact: bool, effects: Array[Effect] = []
) -> Spell:
	var valid := []
	for spell in spells:
		if is_valid_spell(spell, hand, exact, effects):
			valid.append(spell)
	
	if valid.is_empty():
		return null
	elif valid.size() > 1:
		var best: Spell = valid[0]
		var high: float = calc_dmg(_get_hand_from_spell(valid[0], hand, effects), valid[0])

		for spell in valid.slice(1):
			var scoring_hand := _get_hand_from_spell(spell, hand, effects)
			var dmg := calc_dmg(scoring_hand, spell)

			if dmg > high:
				best = spell
				high = dmg

		return best
	else:
		return valid[0]


## Returns [code]true[/code] if given [param hand] works for [param spell].
## If [param exact] is [code]true[/code], then the [param hand] must match the spell exactly.
static func is_valid_spell(
	spell: Spell, hand: Array[Card], exact: bool, effects: Array[Effect] = []
) -> bool:
	if exact and hand.size() != spell.size():
		return false

	sort_cards(hand, true)

	var combos := []
	for i in range(spell.parts()):
		var part := []
		match spell.rank_combo[i]:
			Spell.RankCombo.SET:
				part = _get_valid_sets(hand, spell, i)

			Spell.RankCombo.RUN:
				part = _get_valid_runs(hand, spell, i, effects)

			Spell.RankCombo.ANY when spell.aff_combo[i] == Spell.AffCombo.MATCH_ANY:
				part = _get_valid_match_anys(hand, spell, i)

		if part.size() < spell.quantity[i]:
			return false

		combos.append(part)

	if _get_unique_valid_hand(spell, combos).is_empty():
		return false

	return true


## =====  HELPER FUNCTIONS  ===== ##


## This function recursively combines all valid combinations through each spell part. It checks
## to make sure that each combo is unique from each other.[br]
## i.e. for a full house, we check all valid three-of-a-kinds with all valid pairs
## And pairs have valid combos that include the cards used from the part before which we
## don't want to include.
static func _build_valid_hands(combos: Array, spell: Spell, part:=0, hand:=[]) -> Array:
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
			var finished_hand = _build_valid_hands(combos, spell, part + 1, hand + small_hand)
			# Recursive case: if a card is unique it shows up as an empty array
			if not finished_hand.is_empty():
				hands += finished_hand

	# Recursive case: return any finished hands we completed
	return hands


## Returns [code][true][/code] if [param card1] and [param card2] are matching the 
## affinity [param aff_combo].
static func _check_aff_combo(aff_combo: Spell.AffCombo, card1: Card, card2: Card) -> bool:
	match aff_combo:
		Spell.AffCombo.ANY:
			return true

		Spell.AffCombo.MATCH_ANY:
			return card1.affinity == card2.affinity

		_:
			return false


## Returns [code][true][/code] if [param card1] or [param card2] are matching a wild 
## affinity [param aff_combo].
static func _check_wild_aff(
	aff_combo: Spell.AffCombo, card1: Card, card2: Card, effects: Array[Effect]
) -> bool:
	match aff_combo:
		Spell.AffCombo.MATCH_ANY:
			for effect in effects:
				if effect is Effect.Wild:
					if card1.affinity == effect.affinity or card2.affinity == effect.affinity:
						return true
			return false

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


## Returns a [Dictionary] with the amount of each [member Card.affinity] in [param hand].
static func _count_affs(hand: Array[Card]) -> Dictionary:
	var affs: Dictionary = {}

	for card in hand:
		if card.affinity not in affs.keys():
			affs[card.affinity] = 1
		else:
			affs[card.affinity] += 1

	return affs


## Returns all of the possible combinations that could be made with the cards, but order matters.
## Effectively, if [param cards] has more cards than [param size], it will create different
## combinations of them.[br]
## Note: Assumes [param cards] is already a valid run.
static func _get_run_combinations(cards: Array, size: int) -> Array:
	var combinations := []

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


## Returns an [Array] of [Card] objects that are used to make up the composition of a [Spell].
static func _get_hand_from_spell(spell: Spell, hand: Array[Card], effects: Array[Effect]) -> Array:
	sort_cards(hand, true)

	var combos := []
	for i in range(spell.parts()):
		var part := []
		match spell.rank_combo[i]:
			Spell.RankCombo.SET:
				part = _get_valid_sets(hand, spell, i)

			Spell.RankCombo.RUN:
				part = _get_valid_runs(hand, spell, i, effects)

			Spell.RankCombo.ANY when spell.aff_combo[i] == Spell.AffCombo.MATCH_ANY:
				part = _get_valid_match_anys(hand, spell, i)

		combos.append(part)

	return _get_unique_valid_hand(spell, combos)
			

## Given [param combos], an [Array] of all possible sets, runs, or match anys based on the
## [param spell], return the best scoring hand.
static func _get_unique_valid_hand(spell: Spell, combos: Array) -> Array:
	var combinations := []

	for i in range(spell.parts()):
		combinations.append(_get_valid_combinations(spell, i, combos[i]))

	var hands := _build_valid_hands(combinations, spell)

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
## "Valid" means that it has the proper quantity of unique [Card] objects.
static func _get_valid_combinations(spell: Spell, part: int, hands: Array) -> Array:
	var combos := _get_set_combinations(hands, spell.quantity[part])
	var valid := []

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
				if spell.rank_combo[part] == Spell.RankCombo.SET and card.rank in sets:
					unique = false
					break
				used.append(card)

			if not unique:
				break

			if spell.rank_combo[part] == Spell.RankCombo.SET:
				sets.append(small_hand[0].rank)
		
		# If used has every unique card needed to cast then add to valid combinations
		if used.size() == spell.card_amt[part] * spell.quantity[part]:
			valid.append(used)
	return valid


## Returns all valid sets that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
static func _get_valid_sets(hand: Array[Card], spell: Spell, part: int) -> Array:
	var by_rank := {}

	for card in hand:
		var check := ""
		if card.rank == Card.WIND_RANK:
			check = card.get_wind_str()
		elif card.rank == Card.DRAGON_RANK:
			check = card.get_affinity_str()
		else:
			check = str(card.rank)

		if by_rank.has(check):
			by_rank[check].append(card)
		else:
			by_rank[check] = [card]

	var sets := []

	for cards in by_rank.values():
		if cards.size() >= spell.card_amt[part]:
			sets.append(cards)

	var hands := []
	for s in sets:
		hands += _get_set_combinations(s, spell.card_amt[part])

	return hands


## Returns all valid runs that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
## Runs have additional checkers for Affinity Combos, Face Cards, and Wild Affinities.[br]
## Note: [param hand] must be sorted by rank before using this function.
static func _get_valid_runs(
	hand: Array[Card], spell: Spell, part: int, effects: Array[Effect]
) -> Array:
	var runs := [[hand[0]]]

	for card in hand.slice(1):
		for r in runs:
			if (
				# Card is next rank in set
				(card.rank == r[-1].rank + 1) or   
				# Card is a W (Face card) and is bridging a 2 3 run
				(card.rank == Card.BRIDGE_RANK and r[0].rank == Card.MIN_RANK 
				and r[-1].rank != Card.BRIDGE_RANK)
			):
				# Card is matching affinity combo
				if _check_aff_combo(spell.aff_combo[part], r[-1], card):
					r.append(card)
				# Card could be a Wild affinity
				elif _check_wild_aff(spell.aff_combo[part], r[-1], card, effects):
					# We append the card to the run, but did not mark added so that it can also
					# start its own run if needed
					r.append(card)

		runs.append([card])

	var hands := []
	for r in runs:
		if r.size() >= spell.card_amt[part] and _verify_wilds(r, effects, spell.aff_combo[part]):
			if r.size() > spell.card_amt[part]:
				hands += _get_run_combinations(r, spell.card_amt[part])
			elif r.size() == spell.card_amt[part]:
				hands.append(r)

	#print(hands)
	return hands


## This function will make sure that if there are any wilds in the run, that it doesn't exceed
## the card limit.[br]
## Note: [param run] is assumed to already be a valid run makeup.[br]
## Warning: I expect this function to have unexpected results when mixing multiple wilds in a run.
## Also will act weird if a Wild effect has a 0 card limit, which shouldn't happen anyway.
static func _verify_wilds(run: Array, effects: Array[Effect], aff_combo: Spell.AffCombo) -> bool:
	if aff_combo == Spell.AffCombo.MATCH_ANY:
		if effects.is_empty():
			return true

		var wilds := {}

		for effect in effects:
			if effect is Effect.Wild:
				wilds[effect.affinity] = 0

		for card in run:
			if card.affinity in wilds.keys():
				wilds[card.affinity] += 1

		var i := 0
		for count in wilds.values():
			if count == run.size():
				return true
			if count > effects[i].card_limit:
				return false
			i += 1

	return true


## Returns all valid match anys that could be made with the given [param hand].
## It must match the quantity set by the [param spell].
static func _get_valid_match_anys(hand: Array[Card], spell: Spell, part: int) -> Array:
	var by_aff := {}
	for card in hand:
		if by_aff.has(card.affinity):
			by_aff[card.affinity].append(card)
		else:
			by_aff[card.affinity] = [card]
			
	var sets := []
	for cards in by_aff.values():
		if cards.size() >= spell.card_amt[part]:
			sets.append(cards)

	var hands := []
	for s in sets:
		hands += _get_set_combinations(s, spell.card_amt[part])

	#print(hands)
	return hands