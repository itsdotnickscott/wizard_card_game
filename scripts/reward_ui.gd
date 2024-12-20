extends Control


signal gain_reward(choice: Variant)
signal next_location()


@onready var card_ui := preload("res://scenes/card_ui.tscn")


@onready var rewards_list: VBoxContainer = get_node("RewardsPanel/VBoxContainer")
@onready var choices_panel: Panel = get_node("ChoicePanel")
@onready var tome_ui: VBoxContainer = get_node("ChoicePanel/Tome")
@onready var card_pack_ui: HBoxContainer = get_node("ChoicePanel/CardPack")
@onready var skip_reward_button: Button = get_node("RewardsPanel/SkipButton")
@onready var skip_choice_button: Button = get_node("ChoicePanel/SkipButton")
@onready var next_button: Button = get_node("RewardsPanel/NextButton")
@onready var cover_panel: Panel = get_node("RewardsPanel/CoverPanel")


func set_rewards(location_info: Location) -> void:
	choices_panel.visible = false

	for child in rewards_list.get_children():
		child.queue_free()

	if location_info.gold > 0:
		var button := Button.new()
		button.text = "%d Gold" % location_info.gold
		button.disabled = true
		rewards_list.add_child(button)

	if location_info.dust > 0:
		var button := Button.new()
		button.text = "%d Magic Dust" % location_info.dust
		button.disabled = true
		rewards_list.add_child(button)

	if not location_info.rewards.is_empty():
		skip_reward_button.visible = true
		next_button.visible = false

		for reward in location_info.rewards:
			var button := Button.new()
			button.text = reward.name()
			rewards_list.add_child(button)
			button.pressed.connect(_set_choices.bind(reward, button))


func next_reward() -> void:
	cover_panel.visible = false
	choices_panel.visible = false

	for button in rewards_list.get_children():
		if button.disabled == false:
			return

	skip_reward_button.visible = false
	next_button.visible = true


func _set_choices(reward: Reward, btn: Button) -> void:
	btn.disabled = true
	cover_panel.visible = true

	_reset_choices()

	$ChoicePanel/Count.text = "Choose %d:" % [reward.choice_amt] 

	# Create new labels for each choice
	for choice in reward.choices:
		if choice is Spell or choice is Tarot or choice is Idol:
			var button := Button.new()
			button.text = choice.name
			tome_ui.add_child(button)
			button.pressed.connect(_on_reward_chosen.bind(choice))
			tome_ui.visible = true

		elif choice is Card:
			var card := card_ui.instantiate()
			card_pack_ui.add_child(card)
			card.set_display(choice)
			card.get_node("Button").pressed.connect(_on_reward_chosen.bind(card.info))
			card_pack_ui.visible = true

	choices_panel.visible = true


func _reset_choices() -> void:
	for container in get_tree().get_nodes_in_group("choices"):
		container.visible = false
		for child in container.get_children():
			child.queue_free()


func _on_reward_chosen(choice: Variant) -> void:
	gain_reward.emit(choice)


func _on_next_button_pressed() -> void:
	next_location.emit()


func _on_skip_choice_button_pressed() -> void:
	next_reward()
