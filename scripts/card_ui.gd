extends Control


signal update_selected(card_ui: Node, selected: bool)


@onready var selected_panel = get_node("Selected")
@onready var button = get_node("Button")


var info: Card = null
var selected: bool = false


func select_card(to_select: bool = true) -> void:
	selected = to_select
	selected_panel.visible = selected


## Sets the text of the button to the rank/affinity of the card.
## Should be called after this scene is already instantiated and added as a child to a scene.
func set_display(card: Card) -> void:
	info = card
	button.pressed.connect(_on_card_pressed)

	match info.type:
		Card.Type.NUMBER:
			button.text = str(info.rank)
		Card.Type.WIND:
			button.text = info.get_wind_str()
		Card.Type.DRAGON:
			button.text = "🐉"
		
	button.text += "\n"

	match info.affinity:
		Card.Affinity.DOT:
			button.text += "🧿"
		Card.Affinity.BAMBOO:
			button.text += "🎋"
		Card.Affinity.CHARACTER:
			button.text += "🈺"
		Card.Affinity.RED_DRAGON:
			button.text += "🔴"
		Card.Affinity.GREEN_DRAGON:
			button.text += "🟢"
		Card.Affinity.WHITE_DRAGON:
			button.text += "⚪"
		Card.Affinity.FIRE:
			button.text += "🔥"
		Card.Affinity.WATER:
			button.text += "💧"
		Card.Affinity.EARTH:
			button.text += "🍃"
		Card.Affinity.WIND:
			button.text += "🌫️"
		Card.Affinity.ARCANA:
			button.text += "🎆"


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)