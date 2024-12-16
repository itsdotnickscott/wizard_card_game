extends Control


signal level_up_spell(spell: Spell)
signal upgrade_spell(upgrade: Upgrade)
signal gain_card(card: Card)
signal gain_tarot(tarot: Tarot)


@onready var tome_ui: VBoxContainer = get_node("VictoryPanel/Tome")
@onready var card_pack_ui: HBoxContainer = get_node("VictoryPanel/CardPack")


var choices: Dictionary


func set_reward(reward: Reward) -> void:
	_hide_choices()

	# Delete current labels
	for container in get_tree().get_nodes_in_group("choices"):
		for child in container.get_children():
			container.remove_child(child)

	# Set reward name
	var text: String
	if reward is Reward.Tome:
		text = "Tome"
	elif reward is Reward.CardPack:
		text = "Card Pack"
	elif reward is Reward.TarotPack:
		text = "Tarot Card Pack"

	$VictoryPanel/Reward/Type.text = text 
	$VictoryPanel/Reward/Count.text = "Choose %d:" % [reward.choice_amt] 

	# Create new labels for each spell
	for choice in reward.choices:
		if choice is Spell or choice is Upgrade or choice is Tarot:
			var button := Button.new()
			button.text = choice.name
			tome_ui.add_child(button)
			button.pressed.connect(_on_reward_chosen.bind(choice))
			tome_ui.visible = true

		elif choice is Card:
			card_pack_ui.add_child(choice)
			choice.setup_card_for_ui()
			choice.get_node("Button").pressed.connect(_on_reward_chosen.bind(choice))
			card_pack_ui.visible = true


func _reset_card(card: Card) -> void:
	card.ui_ready = false
	card.select_card(false)
	card.get_node("Button").pressed.disconnect(_on_reward_chosen)
	for child in card_pack_ui.get_children():
		card_pack_ui.remove_child(child)


func _hide_choices() -> void:
	for container in get_tree().get_nodes_in_group("choices"):
		container.visible = false


func _on_reward_chosen(choice: Variant) -> void:
	if choice is Spell:
		level_up_spell.emit(choice)

	elif choice is Upgrade:
		upgrade_spell.emit(choice)

	elif choice is Card:
		_reset_card(choice)
		gain_card.emit(choice)
		
	elif choice is Tarot:
		gain_tarot.emit(choice)