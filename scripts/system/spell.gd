class_name Spell extends Resource


enum Meld { HIGH_CARD = -1, PAIR, RUN, SET }


static var _library = {}


@export var name: String
@export var tome_rarity: Reward.Rarity
@export var melds: Array[Meld]
@export var quantity: Array[int]
@export var base: int
@export var multi: float


func _init(
	spell_name: String, rarity: Reward.Rarity,
	meld_combo: Array[Meld], quant: Array[int], 
	base_dmg: int, mult: float
) -> void:
	if meld_combo.size() != quant.size():
		print("invalid spell - meld comboand quant params all need to be the same size")
		return

	name = spell_name
	melds = meld_combo
	quantity = quant
	base = base_dmg
	multi = mult
	tome_rarity = rarity


func parts() -> int:
	return melds.size()


func get_meld_size(part: int):
	match melds[part]:
		Meld.HIGH_CARD: return 1
		Meld.PAIR: return 2
		_: return 3


func size() -> int:
	var val = 0
	for i in range(parts()):
		val += get_meld_size(i) * quantity[i]
	return val


func _to_string() -> String:
	return name


func level_up() -> void:
	multi += 1
	base += 10


static func init_library() -> void:
	_library = {
		"fizzle": Spell.new(
			"Fizzle", Reward.Rarity.EPIC,
			[Spell.Meld.HIGH_CARD], [1],
			0, 0.5
		),

		"spark": Spell.new(
			"Spark", Reward.Rarity.COMMON,
			[Spell.Meld.PAIR], [1], 
			10, 1.0
		),
		
		"flare": Spell.new(
			"Flare", Reward.Rarity.COMMON,
			[Spell.Meld.RUN], [1],
			20, 2.0
		),

		"blast": Spell.new(
			"Blast", Reward.Rarity.COMMON,
			[Spell.Meld.SET], [1],
			30, 3.0
		),

		"twin_bolt": Spell.new(
			"Twin Bolt", Reward.Rarity.COMMON,
			[Spell.Meld.PAIR], [2],
			20, 2.0
		),

		"weave": Spell.new(
			"Weave", Reward.Rarity.COMMON,
			[Spell.Meld.RUN, Spell.Meld.PAIR], [1, 1],
			25, 3.0
		),

		"rapture": Spell.new(
			"Rapture", Reward.Rarity.COMMON,
			[Spell.Meld.SET, Spell.Meld.PAIR], [1, 1],
			50, 5.0
		)
	}


static func get_spell_library() -> Dictionary:
	return _library


static func get_all_spells() -> Array[Spell]:
	var all: Array[Spell] = []
	all.assign(_library.values())
	return all


static func get_from_id(id: String) -> Spell:
	if _library.has(id):
		return _library[id]
	else:
		return null


static func get_spell_from_meld(meld: Meld) -> Spell:
	if meld == Meld.PAIR:
		return get_from_id("spark")
	elif meld == Meld.RUN:
		return get_from_id("weave")
	elif meld == Meld.SET:
		return get_from_id("blast")
	else:
		return null