class_name Card extends Control


signal update_selected(card, selected)


const MIN_RANK = 1
const BRIDGE_RANK = 10
const WIND_RANK = 12
const DRAGON_RANK = 13


enum Affinity {
	NONE = -1,
	WILD,
	FIRE,
	WATER,
	EARTH,
	WIND,
	ARCANA,
}

enum Direction { NONE, EAST, SOUTH, WEST, NORTH }


@onready var selected_panel = get_node("Selected")
@onready var button = get_node("Button")


@export var rank: int = -1
@export var affinity: Affinity = Affinity.NONE
@export var direction: Direction = Direction.NONE


var selected: bool = false
var ui_ready: bool = false


func select_card(to_select: bool = true) -> void:
	selected = to_select
	selected_panel.visible = selected


func change_aff(to: Affinity) -> void:
	affinity = to
	_set_display()


func change_rank(by: int) -> void:
	rank = (rank + by) % BRIDGE_RANK
	if rank < MIN_RANK: rank = MIN_RANK
	_set_display()


## Edits the button display and sets up UI for button signals. Should be called after being
## added to the scene with [method add_child].
func setup_card_for_ui() -> void:
	_set_display()
	button.pressed.connect(_on_card_pressed)
	ui_ready = true


## Sets up the [member Card.rank] and [member Card.affinity]. Should be called after using 
## [method instantiate] on a [Card] [PackedScene].
func init(val: int, aff: Affinity) -> void:
	rank = val
	affinity = aff


func init_wind(wind: Direction) -> void:
	rank = WIND_RANK
	affinity = Affinity.WIND
	direction = wind


func init_dragon(aff: Affinity) -> void:
	rank = DRAGON_RANK
	affinity = aff


func init_bridge(aff: Affinity) -> void:
	rank = BRIDGE_RANK
	affinity = aff



func get_direction_str() -> String:
	match direction:
		Card.Direction.EAST:
			return "E"
		Card.Direction.SOUTH:
			return "S"
		Card.Direction.WEST:
			return "W"
		Card.Direction.NORTH:
			return "N"
		_:
			return "-"
	

## Sets the text of the button to the rank/affinity of the card.
func _set_display() -> void:
	if rank == WIND_RANK:
		button.text = get_direction_str()
	elif rank == BRIDGE_RANK:
		button.text = "X"
	elif rank == DRAGON_RANK:
		button.text = "🐉"
	else:
		button.text = str(rank)

	button.text += "\n"

	match affinity:
		Affinity.WILD:
			button.text += "❔"
		Affinity.FIRE:
			button.text += "🔥"
		Affinity.WATER:
			button.text += "💧"
		Affinity.EARTH:
			button.text += "🍃"
		Affinity.WIND:
			button.text += "🌫️"
		Affinity.ARCANA:
			button.text += "🎆"


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)


func _to_string() -> String:
	var txt := "Card(%d, %d" % [rank, affinity] 
	if direction != Direction.NONE:
		txt += ", " + get_direction_str()
	txt += ")"
	return txt
