class_name Card extends Control


signal update_selected(card, selected)


enum Element {
	WILD = -1,
	FIRE,
	WATER,
	EARTH,
}


@onready var selected_panel = get_node("Selected")
@onready var button = get_node("Button")


var value: int
var element: Element
var selected: bool = false


func select_card(to_select: bool = true):
	selected = to_select
	selected_panel.visible = selected


## Edits the button display and sets up UI for button signals. Should be called after being
## added to the scene with [method add_child].
func setup_card_for_ui() -> void:
	_set_display()
	button.pressed.connect(_on_card_pressed)


## Sets up the [member Card.value] and [member Card.element]. Should be called after using 
## [method instantiate] on a [Card] [PackedScene].
func init(val, elem) -> void:
	value = val
	element = elem
	

## Sets the text of the button to the value/element of the card.
func _set_display() -> void:
	button.text = str(value) if value != 11 else "W"
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


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)


func _to_string() -> String:
	return "Card(%d, %d)" % [value, element] 


