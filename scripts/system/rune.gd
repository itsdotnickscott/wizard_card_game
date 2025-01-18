class_name Rune extends Resource


enum Mutator {
	NONE = -1, AFFINITY, RANK, DUPLICATE, BURN, BASE, MULTI
}


static var _library: Dictionary = {}


@export var name: String = ""
@export var mutator: Mutator = Mutator.NONE
@export var uses_main_card: bool = false


func _init(new_name: String, eff: Mutator, use_main: bool) -> void:
	name = new_name
	mutator = eff
	uses_main_card = use_main


static func init_library() -> void:
	_library = {
		"aff": Rune.new("Affinity Rune", Mutator.AFFINITY, true),
		"freq": Rune.new("Frequency Rune", Mutator.RANK, true),
		"mirror": Rune.new("Mirror Rune", Mutator.DUPLICATE, true),
		"death": Rune.new("Death Rune", Mutator.BURN, false),
		"strength": Rune.new("Strength Rune", Mutator.BASE, false),
		"power": Rune.new("Power Rune", Mutator.MULTI, false)
	}


static func get_all_runes() -> Array:
	return _library.values()