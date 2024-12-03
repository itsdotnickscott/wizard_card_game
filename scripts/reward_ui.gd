extends Control


signal upgrade_spell(spell: Spell)


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

					if reward is Spell:
						button.text = Analysis.get_spell_info(reward)
						button.pressed.connect(_on_reward_chosen.bind(reward))

					choices_ui.add_child(button)


func _on_reward_chosen(reward: Variant):
		if reward is Spell:
			upgrade_spell.emit(reward)