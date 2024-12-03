extends Control


signal level_up_spell(spell: Spell)
signal upgrade_spell(upgrade: Upgrade)


@onready var choices_ui: VBoxContainer = get_node("VictoryPanel/Choices")


var choices: Dictionary


func set_rewards(rewards: Dictionary):
	choices = rewards

	# Delete current labels
	for child in choices_ui.get_children():
		choices_ui.remove_child(child)

	# Create new labels for each spell
	for i in range(rewards.size()):
		match rewards.keys()[i]:
			Reward.Type.TOME:
				for reward in rewards.values()[i]:
					var button := Button.new()
					button.text = reward.name
					choices_ui.add_child(button)
					button.pressed.connect(_on_reward_chosen.bind(reward))


func _on_reward_chosen(reward: Variant):
	if reward is Spell:
		level_up_spell.emit(reward)
	elif reward is Upgrade:
		upgrade_spell.emit(reward)