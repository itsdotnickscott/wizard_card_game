extends Control


@onready var choices_ui: VBoxContainer = get_node("VictoryPanel/Choices")


var choices: Array = []


func set_rewards(rewards: Array):
	choices = rewards

	# Delete current labels
	for child in choices_ui.get_children():
		choices_ui.remove_child(child)

	# Create new labels for each spell
	for reward in rewards:
		var button := Button.new()

		if reward is Spell:
			button.text = Analysis.get_spell_info(reward)

		choices_ui.add_child(button)

		