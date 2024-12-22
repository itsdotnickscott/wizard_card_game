extends Control


signal cast(selected_cards: Array[Card])
signal discard(selected_cards: Array[Card])
signal sort_hand(by_value: bool)
signal use_tarot(tarot: Tarot, selected_cards: Array[Card])


@onready var card_ui := preload("res://scenes/card_ui.tscn")

@onready var player_hand_ui: HBoxContainer = get_node("Hand")
@onready var player_spell_ui: VBoxContainer = get_node("Spells")
@onready var tarots_ui: VBoxContainer = get_node("Tarots")
@onready var sort_toggle: CheckButton = get_node("SortToggle")


var deck_size: int
var selected_cards: Array[Node] = []
var select_limit: int


## Sets the amount of [Card] objects allowed to be [member Card.selected].
func set_select_limit(val: int) -> void:
	select_limit = val


func set_deck_size(val: int) -> void:
	deck_size = val
	

## Clear the [member selected_cards] list.
func reset_selected_cards() -> void:
	selected_cards = []
	for child in player_hand_ui.get_children():
		child.selected = false
		child.get_node("Selected").visible = false


## Refreshes the Battle UI using the information from the [Player].
func update_display(player: Player, enemy: Enemy) -> void:
	update_player(player)
	update_enemy(enemy)


func update_player(player: Player):
	update_player_hand(player.hand)
	update_player_spells(player.spellbook)
	update_player_tarots(player.tarots)
	update_player_stats(player)
	update_player_idols(player.get_curr_affs())


func update_enemy(enemy: Enemy):
	update_enemy_stats(enemy)


func update_player_stats(player: Player) -> void:
	$PlayerStats/HPValue.text = "%d/%d" % [player.health, player.max_health]
	$PlayerStats/ShieldValue.text = "%d" % [player.total_shield()]
	$PlayerStats/ManaValue.text = "%d/%d" % [player.mana, player.max_mana]
	$PlayerStats/DiscardValue.text = "%d/%d" % [player.discards_left, player.max_discards]
	$PlayerStats/DeckValue.text = "%d/%d" % [player.deck.size(), deck_size]
	$SelectLabel.text = "%d/%d" % [selected_cards.size(), select_limit]


func update_player_idols(affs: Array[Card.Affinity]) -> void:
	var labels := get_tree().get_nodes_in_group("idol_labels")
	for i in range(Player.IDOL_LIMIT):
		labels[i].text = Card.get_affinity_str_from(affs[i])


func update_player_spells(spells: Array[Spell]) -> void:
	# TODO: Optimize a way to only update new/removed spells

	# Delete current labels
	for child in player_spell_ui.get_children():
		# Can be queue freed because spell is represented as a label
		child.queue_free()

	# Create new labels for each spell
	for spell in spells:
		var label := Label.new()
		label.text = Analysis.get_spell_info(spell)
		player_spell_ui.add_child(label)


func update_player_hand(hand: Array[Card]) -> void:
	# TODO: Optimize a way to only update new/removed cards

	# Delete current buttons
	for child in player_hand_ui.get_children():
		_on_card_update_selected(child, false)
		# remove_child is used instead of queue_free because Cards need to stay alive in player hand
		child.queue_free()

	# Create new buttons based on player hand
	for card in hand:
		var new_card := card_ui.instantiate()
		player_hand_ui.add_child(new_card)
		new_card.set_display(card)
		new_card.update_selected.connect(_on_card_update_selected)


func update_player_tarots(tarots: Array[Tarot]) -> void:
	if tarots.is_empty():
		$TarotButton.disabled = true
		return
	else:
		$TarotButton.disabled = false

	# TODO: Optimize a way to only update new/removed tarots

	# Delete current buttons
	for child in tarots_ui.get_children():
		# Can be queue freed because tarot is represented as a button
		child.queue_free()

	# Create new buttons based on player tarots
	for tarot in tarots:
		var button := Button.new()
		button.text = tarot.name
		tarots_ui.add_child(button)
		button.pressed.connect(_on_tarot_card_pressed.bind(tarot))


func update_enemy_stats(
	enemy: Enemy, tot_dmg: float = -1, new_dmg: float = -1, spell_name: String = ""
) -> void:
	$EnemyStats/NameValue.text = "❗  %s  ❗" % [enemy.name]
	$EnemyStats/HPValue.text = "%d/%d" % [enemy.health, enemy.max_health]
	$EnemyStats/AtkValue.text = "%d" % [enemy.attacks[0].damage]
	if new_dmg != -1:
		$EnemyStats/LastSpellValue.text = "%d  (%s)" % [new_dmg, spell_name]
	if tot_dmg != -1:
		$EnemyStats/RoundTotValue.text = "%d" % [tot_dmg]


func reset_round_damage() -> void:
	$EnemyStats/LastSpellValue.text = "--"
	$EnemyStats/RoundTotValue.text = "0" 


func _on_card_update_selected(card: Node, selected: bool) -> void:
	if selected:
		# Undo select if max number of cards already selected
		if selected_cards.size() == select_limit:
			card.select_card(false)
			return

		# Otherwise add card to selected cards list
		selected_cards.append(card)

		if selected_cards.size() == select_limit:
			_disable_unselected_cards()

	else:
		if selected_cards.size() == select_limit:
			_enable_all_cards()

		# Remove card from selected cards list
		selected_cards.erase(card)


	$SelectLabel.text = "%d/%d" % [selected_cards.size(), select_limit]


func _disable_unselected_cards() -> void:
	for card in player_hand_ui.get_children():
		if not card.selected:
			card.button.disabled = true


func _enable_all_cards() -> void:
	for card in player_hand_ui.get_children():
		card.button.disabled = false


func _on_sort_button_toggled(toggled_on: bool) -> void:
	sort_hand.emit(toggled_on)


func _on_discard_button_pressed() -> void:
	discard.emit(_gather_selected_card_info())


func _on_cast_button_pressed() -> void:
	cast.emit(_gather_selected_card_info())


func _on_tarot_card_pressed(tarot: Tarot) -> void:
	use_tarot.emit(tarot, _gather_selected_card_info())


## This function returns the Card object from each CardUI Node. It also unselects each card.
func _gather_selected_card_info() -> Array[Card]:
	var cards: Array[Card] = []

	for card in selected_cards:
		card.select_card(false)
		cards.append(card.info)

	return cards


func _on_tarot_button_pressed() -> void:
	tarots_ui.visible = not tarots_ui.visible
