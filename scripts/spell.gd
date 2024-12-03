class_name Spell extends Resource


enum RankCombo { SET, RUN, ANY }
enum AffCombo { ANY, MATCH_ANY }


static var _library = {}


var name: String
var tome_rarity: Reward.Rarity
var rank_combo: Array[RankCombo]
var aff_combo: Array[AffCombo]
var card_amt: Array[int]
var quantity: Array[int]
var base: int
var multi: float
var upgrades: Array[Upgrade]


func _init(
	spell_name: String, rarity: Reward.Rarity,
	rank: Array[RankCombo], aff: Array[AffCombo], 
	amt: Array[int], quant: Array[int], base_dmg: int, mult: float
) -> void:
	if not (
		rank.size() == aff.size() and aff.size() == amt.size() and amt.size() == quant.size()
	):
		print("invalid spell makeup")

	name = spell_name
	rank_combo = rank
	aff_combo = aff
	card_amt = amt
	quantity = quant
	base = base_dmg
	multi = mult
	tome_rarity = rarity


func parts() -> int:
	return rank_combo.size()


func size() -> int:
	var val = 0
	for i in range(parts()):
		val += card_amt[i] * quantity[i]
	return val


func _to_string() -> String:
	return name


func level_up() -> void:
	multi += 0.5
	base += 10


func upgrade(new_upg: Upgrade) -> void:
	upgrades.append(new_upg)


static func initialize_library() -> void:
	_library = {"spark": Spell.new(
			"Spark", Reward.Rarity.COMMON,
			[Spell.RankCombo.SET], [Spell.AffCombo.ANY], 
			[2], [1], 15, 0.5
		),

		"bolt": Spell.new(
			"Twin Bolt", Reward.Rarity.COMMON,
			[Spell.RankCombo.SET], [Spell.AffCombo.ANY], 
			[2], [2], 30, 0.5
		),

		"blast": Spell.new(
			"Chromatic Blast", Reward.Rarity.COMMON,
			[Spell.RankCombo.SET], [Spell.AffCombo.ANY],
			[3], [1], 30, 1.0
		),
		
		"weave": Spell.new(
			"Elemental Weave", Reward.Rarity.COMMON,
			[Spell.RankCombo.RUN], [Spell.AffCombo.MATCH_ANY], 
			[3], [1], 35, 1.0
		),

		"thread": Spell.new(
			"Unstable Thread", Reward.Rarity.COMMON,
			[Spell.RankCombo.RUN], [Spell.AffCombo.ANY], 
			[5], [1], 30, 1.0
		),

		"chaos": Spell.new(
			"Ray of Chaos", Reward.Rarity.UNCOMMON,
			[Spell.RankCombo.SET, Spell.RankCombo.SET], [Spell.AffCombo.ANY, Spell.AffCombo.ANY], 
			[3, 2], [1, 1], 40, 1.5
		),

		"takeover": Spell.new(
			"Natural Takeover", Reward.Rarity.UNCOMMON,
			[Spell.RankCombo.ANY], [Spell.AffCombo.MATCH_ANY], 
			[5], [1], 50, 2.0
		),

		"fissure": Spell.new(
			"Organic Fissure", Reward.Rarity.UNCOMMON,
			[Spell.RankCombo.RUN], [Spell.AffCombo.MATCH_ANY], 
			[4], [1], 60, 2.5
		),

		"purge": Spell.new(
			"Ultimate Purge", Reward.Rarity.RARE,
			[Spell.RankCombo.SET], [Spell.AffCombo.ANY], 
			[4], [1], 70, 3.0
		),

		"rapture": Spell.new(
			"Intense Rapture", Reward.Rarity.RARE,
			[Spell.RankCombo.RUN], [Spell.AffCombo.MATCH_ANY], 
			[5], [1], 80, 4.0
		),
	}


static func get_spell_library() -> Dictionary:
	return _library


static func get_all_spells() -> Array:
	return _library.values()


static func get_from_id(id: String) -> Spell:
	if _library.has(id):
		return _library[id]
	else:
		return null