extends Node2D


enum State {
	PLAYER_CHOOSE, PLAYER_ANIMATION, ENEMY_ATTACK, OUTCOME, MAP
}


@onready var player: Player = get_node("Player")
@onready var enemy: Enemy = get_node("Enemy")

@onready var battle_ui: Control = get_node("UserInterface/BattleUI")
@onready var reward_ui: Control = get_node("UserInterface/RewardUI")
@onready var defeat_ui: Control = get_node("UserInterface/DefeatUI")
@onready var escape_ui: Control = get_node("UserInterface/EscapeUI")


var curr_state: State
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
	escape_ui.visible = false

	# Basic enemy progression for now
	enemy.max_health *= 2
	enemy.health = enemy.max_health
	enemy.attack += 10

	start_battle()
	

## The [Player] draws to the [member Player.hand_limit] and sorts their [member Player.hand].
func player_turn() -> void:
	curr_state = State.PLAYER_CHOOSE
	battle_ui.reset_selected_cards()
	player.draw_to_limit()
	Analysis.sort_cards(player.hand, battle_ui.sort_toggle.button_pressed)
	battle_ui.update_display(player, enemy)


func enemy_turn() -> void:
	curr_state = State.ENEMY_ATTACK

	var dmg := enemy.attack
	player.take_dmg(dmg)

	print("Player takes %d damage" % [dmg])

	battle_ui.update_player_stats(player)

	if player.health <= 0:
		game_over()
		return

	player_turn()


## The [Player] uses the cast action.
func cast_action(selected_cards: Array[Card]) -> void:
	curr_state = State.PLAYER_ANIMATION
	var spell := player.cast_cards(selected_cards)

	if spell == null:
		print("No spell found!")
	else:
		var dmg := Analysis.calc_dmg(selected_cards, spell)
		enemy.take_dmg(dmg)
		total_dmg += dmg

		print("Enemy takes %d damage (%s)" % [dmg, spell.name])

		if enemy.health <= 0:
			battle_end()
			return

		battle_ui.update_enemy_stats(enemy, dmg, total_dmg)

	if player.mana == 0:
		out_of_mana()
		return
	
	enemy_turn()


## The [Player] uses the discard action.
func discard_action(selected_cards: Array[Card]) -> void:
	player.discard_cards(selected_cards)
	player_turn()


func battle_end():
	curr_state = State.OUTCOME
	reward_ui.set_rewards(Reward.get_random_reward())
	reward_ui.visible = true
	battle_ui.visible = false
	


func out_of_mana():
	curr_state = State.OUTCOME
	escape_ui.set_escape_damage(enemy.attack * 3)
	escape_ui.visible = true
	battle_ui.visible = false


func game_over() -> void:
	curr_state = State.OUTCOME
	defeat_ui.visible = true
	battle_ui.visible = false


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
	player.level_up_spell(spell)
	next_battle()


func _on_insta_win_pressed():
	enemy.health = 0
	battle_end()


func _on_escape(dmg: int):
	player.take_dmg(dmg)
	print("Player escapes and takes %d damage" % [dmg])

	if player.health <= 0:
		game_over()
		return
	
	next_battle()
