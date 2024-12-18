class_name Card extends Control


signal update_selected(card, selected)


const MIN_RANK = 2
const FACE_RANK = 11


enum Affinity {
	NONE = -1,
	WILD,
	FIRE,
	WATER,
	EARTH,
	ARCANA,
}


@onready var selected_panel = get_node("Selected")
@onready var button = get_node("Button")


@export var rank: int
@export var affinity: Affinity

var selected: bool = false
var ui_ready: bool = false


func select_card(to_select: bool = true) -> void:
	selected = to_select
	selected_panel.visible = selected


func change_aff(to: Affinity) -> void:
	affinity = to
	_set_display()


func change_rank(by: int) -> void:
	rank = (rank + by) % FACE_RANK
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
	

## Sets the text of the button to the rank/affinity of the card.
func _set_display() -> void:
	button.text = str(rank) if rank != 11 else "W"
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
		Affinity.ARCANA:
			button.text += "🎆"


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)


func _to_string() -> String:
	return "Card(%d, %d)" % [rank, affinity] 


