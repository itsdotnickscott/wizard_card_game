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

	shake_value(to_multi)
	update_labels()


func shake_value(is_multi: bool) -> void:
	var value = $Panel/Spell/Multi/Label if is_multi else $Panel/Spell/Base/Label

	var tween = get_tree().create_tween()
	tween.tween_property(value, "rotation_degrees", 6, 0.075)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(value, "rotation_degrees", -6, 0.075)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(value, "rotation_degrees", 2, 0.075)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(value, "rotation_degrees", -2, 0.075)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(value, "rotation_degrees", 0, 0.075)\
	.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)


func show_card(card: Card, scored: bool) -> void:
	var new_card := card_ui.instantiate()
	$Panel/Hand.add_child(new_card)
	new_card.set_display(card)
	if not scored:
		new_card.disable()


func damage_label() -> void:
	for card in $Panel/Hand.get_children():
		card.queue_free()

	var label = dmg_label.instantiate()
	label.set_damage(base * multi)
	label.position = Vector2(820,280)
	add_child(label)