extends Control


signal reward_chosen(choice: Variant)


@onready var card_ui := preload("res://scenes/card_ui.tscn")

@onready var count_label: Label = get_node("Choices/Count")
@onready var choice_list: VBoxContainer = get_node("Choices/List")
@onready var card_list: HBoxContainer = get_node("Choices/Cards")


func _reset_choices():
	for container in [choice_list, card_list]:
		container.visible = false
		for child in container.get_children():
			child.queue_free()


func set_choices(reward: Reward):
	_reset_choices()

	count_label.text = "Choose %d:" % [reward.choice_amt] 

	# Create new labels for each choice
	for choice in reward.choices:
		if choice is Card:
			var card := card_ui.instantiate()
			card_list.add_child(card)
			card.set_display(choice)
			card.get_node("Button").pressed.connect(_on_reward_chosen.bind(card.info))
			card_list.visible = true
			
		else:
			var button := Button.new()
			if choice is Spell:
				button.text = Analysis.get_spell_info(choice)
			else:
				button.text = choice.name
			choice_list.add_child(button)
			button.pressed.connect(_on_reward_chosen.bind(choice))
			choice_list.visible = true


func _on_reward_chosen(choice: Variant):
	reward_chosen.emit(choice)