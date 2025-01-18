extends Control


signal gain_reward(choice: Variant)
signal next_location()


@onready var victory_panel: Panel = get_node("Victory")
@onready var rewards_list: VBoxContainer = get_node("Victory/VBoxContainer")
@onready var skip_reward_button: Button = get_node("Victory/SkipButton")
@onready var next_button: Button = get_node("Victory/NextButton")

@onready var reward_handler: Control = get_node("RewardHandler")
@onready var basic_reward_ui: Control = get_node("RewardHandler/BasicRewardUI")
@onready var rune_reward_ui: Control = get_node("RewardHandler/RuneRewardUI")


func set_rewards(location: Location, player: Player) -> void:
	reward_handler.visible = false

	for child in rewards_list.get_children():
		child.queue_free()

	# Create Gold Button
	if location.gold > 0:
		var button := Button.new()
		button.text = "%d Gold" % location.gold
		button.disabled = true
		rewards_list.add_child(button)

	# Create Dust Button
	if location.dust > 0:
		var button := Button.new()
		button.text = "%d Magic Dust" % location.dust
		button.disabled = true
		rewards_list.add_child(button)

	# Create button for each reward
	if not location.rewards.is_empty():
		skip_reward_button.visible = true
		next_button.visible = false

		for reward in location.rewards:
			var button := Button.new()
			button.text = Reward.to_str(reward)
			rewards_list.add_child(button)
			button.pressed.connect(_handle_reward.bind(reward, button, player))


func next_reward() -> void:
	victory_panel.visible = true
	reward_handler.visible = false

	for button in rewards_list.get_children():
		if button.disabled == false:
			return

	skip_reward_button.visible = false
	next_button.visible = true


func _handle_reward(rew_type: Reward.Type, btn: Button, player: Player) -> void:
	btn.disabled = true
	victory_panel.visible = false

	basic_reward_ui.visible = false
	rune_reward_ui.visible = false

	var reward = Reward.get_random(rew_type, player)
	var choice = reward.choices[0]

	if choice is Spell or choice is Tarot or choice is Idol or choice is Relic or choice is Card:
		basic_reward_ui.set_choices(reward)
		basic_reward_ui.visible = true

	reward_handler.visible = true


func _on_reward_chosen(choice: Variant) -> void:
	gain_reward.emit(choice)


func _on_next_button_pressed() -> void:
	next_location.emit()


func _on_skip_choice_button_pressed() -> void:
	next_reward()
