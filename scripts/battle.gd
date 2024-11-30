extends Node2D


@onready var player: Player = get_node("Player")
@onready var enemy: Enemy = get_node("Enemy")

@onready var battle_ui: Control = get_node("BattleUI")
@onready var reward_ui: Control = get_node("RewardUI")


var total_dmg: float = 0.0


## Currently called in [method _ready].
func start_battle() -> void:
	total_dmg = 0.0
	player.battle_start()
	battle_ui.set_deck_size(player.deck.size())

	# For now, only the player gets a turn
	player_turn()


func next_battle() -> void:
	battle_ui.visible = true
	reward_ui.visible = false

	start_battle()
	

## The [Player] draws to the [member Player.hand_limit] and sorts their [member Player.hand].
func player_turn() -> void:
	battle_ui.reset_selected_cards()
	player.draw_to_limit()
	Analysis.sort_cards(player.hand, battle_ui.sort_toggle.button_pressed)
	battle_ui.update_display(player, enemy)


## The [Player] uses the cast action.
func cast_action(selected_cards: Array[Card]) -> void:
	var spell := player.cast_cards(selected_cards)

	if spell == null:
		print("No spell found!")
	else:
		var dmg := Analysis.calc_dmg(selected_cards, spell)
		print(spell.name + " - ", dmg)
		enemy.take_dmg(dmg)
		total_dmg += dmg

		if enemy.health < 0:
			battle_end()

		battle_ui.update_enemy_stats(enemy, dmg, total_dmg)
	
	player_turn()


## The [Player] uses the discard action.
func discard_action(selected_cards: Array[Card]) -> void:
	player.discard_cards(selected_cards)
	player_turn()


func _ready() -> void:
	battle_ui.set_select_limit(player.select_limit)
	battle_ui.reset_selected_cards()
	battle_ui.update_display(player, enemy)

	# For now, the battle starts immediately after ready
	start_battle()


func _on_battle_ui_sort_hand(by_value: bool) -> void:
	Analysis.sort_cards(player.hand, by_value)
	battle_ui.update_player_hand(player.hand)


func _on_reward_ui_upgrade_spell(spell: Spell) -> void:
	player.upgrade_spell(spell)
	next_battle()


func _on_insta_win_pressed():
	enemy.health = 0
	battle_end()

func battle_end():
	reward_ui.visible = true
	battle_ui.visible = false
	reward_ui.set_rewards(Reward.get_random_rewards(3, Reward.Type.TOME))
