class_name Relic extends Resource


static var _library = {}


@export var name: String = ""
@export var effect: Effect = null


func _init(new_name: String, eff: Effect) -> void:
	name = new_name
	effect = eff


static func init_library() -> void:
	_library = {
		"basepair": Relic.new(
			"Pair +20 Base", Effect.AddDamage.new(20, false, Effect.Condition.CONTAINS_PAIR)
		),

		"baserun": Relic.new(
			"Run +30 Base", Effect.AddDamage.new(30, false, Effect.Condition.CONTAINS_RUN)
		),

		"baseset": Relic.new(
			"Set +40 Base", Effect.AddDamage.new(40, false, Effect.Condition.CONTAINS_SET)
		),

		"multipair": Relic.new(
			"Pair +2 Multi", Effect.AddDamage.new(2, true, Effect.Condition.CONTAINS_PAIR)
		),

		"multirun": Relic.new(
			"Run +3 Multi", Effect.AddDamage.new(3, true, Effect.Condition.CONTAINS_RUN)
		),

		"multiset": Relic.new(
			"Set +4 Multi", Effect.AddDamage.new(4, true, Effect.Condition.CONTAINS_SET)
		),

		"basic": Relic.new(
			"All +1 Multi", Effect.AddDamage.new(1, true, Effect.Condition.NONE)
		)
	}


static func get_all_relics() -> Array[Relic]:
	var all: Array[Relic] = []
	all.assign(_library.values())
	return all