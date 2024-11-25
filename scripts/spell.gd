class_name Spell extends Resource


enum RankCombo { RUN, SET, }
enum ElemCombo { ANY, MATCH_ANY }


var name: String
var rank_combo: RankCombo
var elem_combo: ElemCombo
var card_amt: int
var quantity: int
var base: int
var multi: float


func _init(
	spell_name: String, 
	val: RankCombo, elem: ElemCombo, 
	size: int, quant: int, base_dmg: int, mult: float
):
	name = spell_name
	rank_combo = val
	elem_combo = elem
	card_amt = size
	quantity = quant
	base = base_dmg
	multi = mult