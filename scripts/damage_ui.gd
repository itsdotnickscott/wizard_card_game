extends Control


@onready var dmg_label := preload("res://scenes/damage_label.tscn")
@onready var card_ui := preload("res://scenes/card_ui.tscn")


var base: int = 0
var multi: float = 0


func set_base_spell(spell: Spell) -> void:
	base = spell.base
	multi = spell.multi

	$Panel/Spell/Name.text = spell.name
	update_labels()


func update_labels() -> void:
	$Panel/Spell/Base/Label.text = str(base)
	$Panel/Spell/Multi/Label.text = "%0.1f" % [multi]


func add(to_multi: bool, by: int) -> void:
	if to_multi:
		multi += by
	else:
		base += by
	
	update_labels()


func show_card(card: Card) -> void:
	var new_card := card_ui.instantiate()
	$Panel/Hand.add_child(new_card)
	new_card.set_display(card)


func damage_label() -> void:
	for card in $Panel/Hand.get_children():
		card.queue_free()

	var label = dmg_label.instantiate()
	label.set_damage(base * multi)
	label.position = Vector2(820,280)
	add_child(label)