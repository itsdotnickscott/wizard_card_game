class_name Card extends Control


signal update_selected(card, selected)


enum Element {
	WILD = -1,
	FIRE,
	WATER,
	EARTH,
	ARCANA,
}


@onready var selected_panel = get_node("Selected")
@onready var button = get_node("Button")


var rank: int
var element: Element
var selected: bool = false

var ui_ready: bool = false


func select_card(to_select: bool = true):
	selected = to_select
	selected_panel.visible = selected


## Edits the button display and sets up UI for button signals. Should be called after being
## added to the scene with [method add_child].
func setup_card_for_ui() -> void:
	_set_display()
	button.pressed.connect(_on_card_pressed)
	ui_ready = true


## Sets up the [member Card.rank] and [member Card.element]. Should be called after using 
## [method instantiate] on a [Card] [PackedScene].
func init(val, elem) -> void:
	rank = val
	element = elem
	

## Sets the text of the button to the rank/element of the card.
func _set_display() -> void:
	button.text = str(rank) if rank != 11 else "W"
	button.text += "\n"

	match element:
		Element.WILD:
			button.text += "❔"
		Element.FIRE:
			button.text += "🔥"
		Element.WATER:
			button.text += "💧"
		Element.EARTH:
			button.text += "🍃"
		Element.ARCANA:
			button.text += "🎆"


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)


func _to_string() -> String:
	return "Card(%d, %d)" % [rank, element] 


