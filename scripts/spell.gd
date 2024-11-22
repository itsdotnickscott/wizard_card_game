class_name Spell extends Resource


enum ValCombo { RUN, SET, }
enum ElemCombo { ANY, MATCH_ANY }


var name: String
var val_combo: ValCombo
var elem_combo: ElemCombo
var card_amt: int
var multi: float


func _init(spell_name: String, val: ValCombo, elem: ElemCombo, size: int, mult: float):
	name = spell_name
	val_combo = val
	elem_combo = elem
	card_amt = size
	multi = mult