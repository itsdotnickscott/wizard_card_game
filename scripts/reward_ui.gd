extends Control


signal gain_reward(choice: Variant)
signal next_location()


@onready var card_ui := preload("res://scenes/card_ui.tscn")


@onready var rewards_list: VBoxContainer = get_node("Rewards/VBoxContainer")
@onready var skip_reward_button: Button = get_node("Rewards/SkipButton")
@onready var next_button: Button = get_node("Rewards/NextButton")
@onready var cover_panel: Panel = get_node("Rewards/CoverPanel")
@onready var choices_panel: Panel = get_node("Choices")
@onready var count_label: Label = get_node("Choices/Count")
@onready var tome_ui: VBoxContainer = get_node("Choices/Tome")
@onready var card_pack_ui: HBoxContainer = get_node("Choices/CardPack")
@onready var skip_choice_button: Button = get_node("Choices/SkipButton")


func set_rewards(location: Location, player: Player) -> void:
	choices_panel.visible = false

	for child in rewards_list.get_children():
		child.queue_free()

	if location.gold > 0:
		var button := Button.new()
		button.text = "%d Gold" % location.gold
		button.disabled = true
		rewards_list.add_child(button)

	if location.dust > 0:
		var button := Button.new()
		button.text = "%d Magic Dust" % location.dust
		button.disabled = true
		rewards_list.add_child(button)

	if not location.rewards.is_empty():
		skip_reward_button.visible = true
		next_button.visible = false

		for reward in location.rewards:
			var button := Button.new()
			button.text = Reward.to_str(reward)
			rewards_list.add_child(button)
			button.pressed.connect(_set_choices.bind(reward, button, player))


func next_reward() -> void:
	cover_panel.visible = false
	choices_panel.visible = false

	for button in rewards_list.get_children():
		if button.disabled == false:
			return

	skip_reward_button.visible = false
	next_button.visible = true


func _set_choices(rew_type: Reward.Type, btn: Button, player: Player) -> void:
	btn.disabled = true
	cover_panel.visible = true

	_reset_choices()

	var reward = Reward.get_random(rew_type, player)

	count_label.text = "Choose %d:" % [reward.choice_amt] 

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
