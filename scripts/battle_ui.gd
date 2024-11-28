extends Control


signal cast(selected_cards: Array[Card])
signal discard(selected_cards: Array[Card])
signal sort_hand(by_value: bool)


@onready var player_hand_ui: HBoxContainer = get_node("Hand")
@onready var player_spell_ui: VBoxContainer = get_node("Spells")
@onready var sort_toggle: CheckButton = get_node("SortToggle")


var deck_size: int
var selected_cards: Array[Card] = []
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
	update_player_hand(player.hand)
	update_player_spells(player.spellbook)
	update_player_stats(player)
	update_enemy_stats(enemy)


func update_player_stats(player: Player) -> void:
	$PlayerStats/HPValue.text = "%d/%d" % [player.health, player.max_health]
	$PlayerStats/ManaValue.text = "%d/%d" % [player.mana, player.max_mana]
	$PlayerStats/DiscardValue.text = "%d/%d" % [player.discards_left, player.max_discards]
	$PlayerStats/DeckValue.text = "%d/%d" % [player.deck.size(), deck_size]
	$SelectLabel.text = "%d/%d" % [selected_cards.size(), select_limit]


func update_player_spells(spells: Array[Spell]) -> void:
	# TODO: Optimize a way to only update new/removed spells

	# Delete current labels
	for child in player_spell_ui.get_children():
		player_spell_ui.remove_child(child)

	# Create new labels for each spell
	for spell in spells:
		var label := Label.new()
		label.text = Analysis.get_spell_info(spell)
		player_spell_ui.add_child(label)


func update_player_hand(hand: Array[Card]) -> void:
	# TODO: Optimize a way to only update new/removed cards

	# Delete current buttons
	for child in player_hand_ui.get_children():
		player_hand_ui.remove_child(child)

	# Create new buttons based on player hand
	for card in hand:
		player_hand_ui.add_child(card)
		if not card.ui_ready:
			card.setup_card_for_ui()
			card.update_selected.connect(_on_card_update_selected)


func update_enemy_stats(enemy: Enemy, new_dmg: float = -1, tot_dmg: float = -1) -> void:
	$EnemyStats/HPValue.text = "%d/%d" % [enemy.health, enemy.max_health]
	if new_dmg != -1 and tot_dmg != -1:
		$EnemyStats/TotDmgValue.text = "%d" % [tot_dmg]
		$EnemyStats/LstSpellValue.text = "%d" % [new_dmg]



func _on_card_update_selected(card: Card, selected: bool) -> void:
	if selected:
		# Undo select if max number of cards already selected
		if selected_cards.size() == select_limit:
			card.select_card(false)
			return

		# Otherwise add card to selected cards list
		selected_cards.append(card)

	else:
		# Remove card from selected cards list
		selected_cards.erase(card)

	$SelectLabel.text = "%d/%d" % [selected_cards.size(), select_limit]


func _on_sort_button_toggled(toggled_on: bool) -> void:
	sort_hand.emit(toggled_on)


func _on_discard_button_pressed() -> void:
	discard.emit(selected_cards)


func _on_cast_button_pressed() -> void:
	cast.emit(selected_cards)
