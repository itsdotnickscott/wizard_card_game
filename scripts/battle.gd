extends Node2D


@onready var player: Player = get_node("Player")
@onready var battle_ui: Control = get_node("BattleUI")


## Currently called in [method _ready].
func start_battle() -> void:
	player.battle_start()

	# For now, only the player gets a turn
	player_turn()
	

## The [Player] draws to the [member Player.hand_limit] and sorts their [member Player.hand].
func player_turn() -> void:
	battle_ui.reset_selected_cards()
	player.draw_to_limit()
	player.sort_hand(battle_ui.sort_toggle.button_pressed)
	battle_ui.update_display(player)


## The [Player] uses the cast action.
func cast_action(selected_cards: Array[Card]) -> void:
	player.cast_cards(selected_cards)
	player_turn()


## The [Player] uses the discard action.
func discard_action(selected_cards: Array[Card]) -> void:
	player.discard_cards(selected_cards)
	player_turn()


func _ready() -> void:
	battle_ui.set_select_limit(player.select_limit)
	battle_ui.reset_selected_cards()
	battle_ui.update_display(player)

	# For now, the battle starts immediately after ready
	start_battle()


func _on_battle_ui_sort_hand(by_value: bool) -> void:
	player.sort_hand(by_value)
	battle_ui.update_display(player)



