class_name Card extends Resource


const MIN_RANK = 1
const BRIDGE_RANK = 10
const WIND_RANK = 12
const DRAGON_RANK = 13


enum Type {
	NONE = -1, NUMBER, WIND, DRAGON
}


enum Affinity {
	NONE = -1,
	DOT,
	BAMBOO,
	CHARACTER,
	RED_DRAGON,
	GREEN_DRAGON,
	WHITE_DRAGON,
	FIRE,
	WATER,
	EARTH,
	WIND,
	ARCANA,
}

enum Wind { NONE, EAST, SOUTH, WEST, NORTH }


@export var type: Type = Type.NONE
@export var rank: int = -1
@export var affinity: Affinity = Affinity.NONE
@export var wind: Wind = Wind.NONE


func change_aff(to: Affinity) -> void:
	affinity = to


func change_rank(by: int) -> void:
	rank = (rank + by) % BRIDGE_RANK
	if rank < MIN_RANK: rank = MIN_RANK


## Sets up the [member Card.rank] and [member Card.affinity]. Should be called after using 
## [method instantiate] on a [Card] [PackedScene].
func _init(card_type: Card.Type, aff: int, val: int = -1) -> void:
	type = card_type

	match type:
		Card.Type.NUMBER:
			rank = val
			affinity = aff as Card.Affinity

		Card.Type.WIND:
			rank = WIND_RANK
			affinity = Affinity.WIND
			wind = aff as Card.Wind

		Card.Type.DRAGON:
			rank = DRAGON_RANK
			affinity = aff as Card.Affinity


func get_affinity_str() -> String:
	match affinity:
		Affinity.RED_DRAGON:
			return "Red Dragon"
		Affinity.GREEN_DRAGON:
			return "Green Dragon"
		Affinity.WHITE_DRAGON:
			return "White Dragon"
		_:
			return "-"


func get_wind_str() -> String:
	match wind:
		Wind.EAST:
			return "E"
		Wind.SOUTH:
			return "S"
		Wind.WEST:
			return "W"
		Wind.NORTH:
			return "N"
		_:
			return "-"


func _to_string() -> String:
	var txt := "Card(%d, %d" % [rank, affinity] 
	if wind != Wind.NONE:
		txt += ", " + get_wind_str()
	txt += ")"
	return txt
