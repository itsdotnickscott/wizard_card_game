class_name Spell extends Resource


enum RankCombo { SET, RUN, ANY }
enum ElemCombo { ANY, MATCH_ANY }


var name: String
var rank_combo: Array[RankCombo]
var elem_combo: Array[ElemCombo]
var card_amt: Array[int]
var quantity: Array[int]
var base: int
var multi: float


func _init(
	spell_name: String, 
	rank: Array[RankCombo], elem: Array[ElemCombo], 
	amt: Array[int], quant: Array[int], base_dmg: int, mult: float
) -> void:
	if not (
		rank.size() == elem.size() and elem.size() == amt.size() and amt.size() == quant.size()
	):
		print("invalid spell makeup")

	name = spell_name
	rank_combo = rank
	elem_combo = elem
	card_amt = amt
	quantity = quant
	base = base_dmg
	multi = mult


func parts() -> int:
	return rank_combo.size()


func size() -> int:
	var val = 0
	for i in range(parts()):
		val += card_amt[i] * quantity[i]
	return val


func _to_string() -> String:
	return name


static func get_spell_library() -> Dictionary:
	return {
		"spark": Spell.new(
			"Spark", 
			[Spell.RankCombo.SET], [Spell.ElemCombo.ANY], 
			[2], [1], 15, 1.0
		),

		"bolt": Spell.new(
			"Twin Bolt",
			[Spell.RankCombo.SET], [Spell.ElemCombo.ANY], 
			[2], [2], 30, 1.0
		),

		"blast": Spell.new(
			"Chromatic Blast", 
			[Spell.RankCombo.SET], [Spell.ElemCombo.ANY],
			[3], [1], 10, 2.0
		),

		"weave": Spell.new(
			"Elemental Weave", 
			[Spell.RankCombo.RUN], [Spell.ElemCombo.MATCH_ANY], 
			[3], [1], 15, 2.0
		),

		"thread": Spell.new(
			"Unstable Thread", 
			[Spell.RankCombo.RUN], [Spell.ElemCombo.ANY], 
			[5], [1], 15, 3.0
		),

		"ray": Spell.new(
			"Ray of Chaos", 
			[Spell.RankCombo.SET, Spell.RankCombo.SET], [Spell.ElemCombo.ANY, Spell.ElemCombo.ANY], 
			[3, 2], [1, 1], 10, 3.0
		),

		"takeover": Spell.new(
			"Natural Takeover", 
			[Spell.RankCombo.ANY], [Spell.ElemCombo.MATCH_ANY], 
			[5], [1], 20, 3.0
		),

		"fissure": Spell.new(
			"Organic Fissure", 
			[Spell.RankCombo.RUN], [Spell.ElemCombo.MATCH_ANY], 
			[4], [1], 15, 3.0
		),

		"rapture": Spell.new(
			"Intense Rapture", 
			[Spell.RankCombo.SET], [Spell.ElemCombo.ANY], 
			[4], [1], 10, 3.0
		),

		"purge": Spell.new(
			"Chaotic Purge", 
			[Spell.RankCombo.RUN], [Spell.ElemCombo.MATCH_ANY], 
			[5], [1], 10, 3.0
		),
	}


static func get_all_spells() -> Array[Spell]:
	var spells: Array[Spell] = []
	for spell in get_spell_library().values():
		spells.append(spell)
	return spells


static func get_from_id(id: String) -> Spell:
	var lib = get_spell_library()

	if lib.has(id):
		return lib[id]
	else:
		return null