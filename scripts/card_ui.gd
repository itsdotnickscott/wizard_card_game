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
	button.text = card.get_rank_str() + "\n" + card.get_affinity_str()


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)