extends Node2D


@onready var player: Player = get_node("Player")
@onready var enemy: Enemy = get_node("Enemy")
@onready var battle_ui: Control = get_node("BattleUI")


var total_dmg: float = 0.0


## Currently called in [method _ready].
func start_battle() -> void:
	total_dmg = 0.0
	player.battle_start()

	# For now, only the player gets a turn
	player_turn()
	

## The [Player] draws to the [member Player.hand_limit] and sorts their [member Player.hand].
func player_turn() -> void:
	battle_ui.reset_selected_cards()
	player.draw_to_limit()
	player.sort_cards(player.hand, battle_ui.sort_toggle.button_pressed)
	battle_ui.update_display(player, enemy)


## The [Player] uses the cast action.
func cast_action(selected_cards: Array[Card]) -> void:
	player.cast_cards(selected_cards)

	var dmg = player.calc_dmg(selected_cards)
	enemy.take_dmg(dmg)
	total_dmg += dmg
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
	player.sort_cards(player.hand, by_value)
	battle_ui.update_player_hand(player.hand)



