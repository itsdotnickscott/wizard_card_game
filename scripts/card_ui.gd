extends Control


signal update_selected(card_ui: Node, selected: bool)


@onready var button = get_node("Button")
@onready var selected_panel = get_node("Selected")
@onready var rank_label = get_node("Button/Rank")
@onready var aff_label = get_node("Button/Affinity")


var info: Card = null
var selected: bool = false


func select_card(to_select: bool = true) -> void:
	selected = to_select
	selected_panel.visible = selected
	position.y = -20 if selected else 0


## Sets the text of the button to the rank/affinity of the card.
## Should be called after this scene is already instantiated and added as a child to a scene.
func set_display(card: Card) -> void:
	info = card

	rank_label.text = card.get_rank_str()
	aff_label.text = card.get_affinity_str()


func _on_card_pressed() -> void:
	select_card(not selected)
	update_selected.emit(self, selected)