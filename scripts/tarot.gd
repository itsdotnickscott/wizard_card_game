class_name Tarot extends Resource


"""

The Fool:
The High Priestess:
The Hierophant:
The Lovers:
The Chariot:
The Hermit:
The Wheel of Fortune:
Justice:
The Hanged Man:
Death:
Temperance:
The Devil:
The Tower:
Judgement:


Rank-Based Tarot

	Strength: Increase the rank of 2 cards by 1

Affinity-Based Tarots

	The Magician: Convert 2 cards to the Arcana affinity
	The Empress: Convert 2 cards to the Water affinity
	The Emperor:
	The Star:
	The Moon:
	The Sun: Convert 2 cards to the Fire affinity
	The World: Convert 2 cards to the Earth affinity

"""


static var _library = {}


@export var name: String = ""
@export var effect: Effect = null


func _init(new_name: String, eff: Effect) -> void:
	name = new_name
	effect = eff


static func initialize_library() -> void:
	_library = {
		"magician": Tarot.new("The Magician", Effect.ChangeAff.new(Card.Affinity.ARCANA, 1)),
		"empress": Tarot.new("The Empress", Effect.ChangeAff.new(Card.Affinity.WATER, 1)),
		"sun": Tarot.new("The Sun", Effect.ChangeAff.new(Card.Affinity.FIRE, 1)),
		"world": Tarot.new("The World", Effect.ChangeAff.new(Card.Affinity.EARTH, 1)),
		"strength": Tarot.new("Strength", Effect.ChangeRank.new(1, 1))
	}


static func get_all_tarots() -> Array:
	return _library.values()