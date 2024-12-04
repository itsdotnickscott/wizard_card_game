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
	enemy.max_health = int(enemy.max_health * 1.5)
	enemy.health = enemy.max_health
	enemy.attack += 10

	start_battle()
	

## The [Player] draws to the [member Player.hand_limit] and sorts their [member Player.hand].
func player_turn() -> void:
	print()

	if player.mana == 0:
		out_of_mana()
		return

	curr_state = State.PLAYER_CHOOSE

	battle_ui.reset_selected_cards()
	player.draw_to_limit()
	Analysis.sort_cards(player.hand, battle_ui.sort_toggle.button_pressed)

	process_effects(player, player.start_turn_effects)

	battle_ui.update_display(player, enemy)


func enemy_turn() -> void:
	print()

	curr_state = State.ENEMY_ATTACK

	process_effects(enemy, enemy.start_turn_effects)

	print("Enemy - Basic Attack")

	var dmg := enemy.attack
	player.take_dmg(dmg)

	battle_ui.update_player_stats(player)

	if player.health <= 0:
		game_over()
		return

	process_effects(enemy, enemy.end_turn_effects)

	player_turn()


## The [Player] uses the cast action.
func cast_action(selected_cards: Array[Card]) -> void:
	curr_state = State.PLAYER_ANIMATION
	var spell := player.cast_cards(selected_cards)

	if spell == null:
		print("Player - Fizzle! (Invalid Spell)")
	else:
		print("Player - ", spell.name)

		var dmg := Analysis.calc_dmg(selected_cards, spell)
		enemy.take_dmg(dmg)
		total_dmg += dmg

		if enemy.health <= 0:
			battle_end()
			return

		if spell.upgrades.size() > 0:
			apply_spell_upgrades(spell, selected_cards)

		battle_ui.update_enemy_stats(enemy, total_dmg, dmg, spell.name)

	process_effects(player, player.end_turn_effects)
	
	enemy_turn()


func apply_spell_upgrades(spell: Spell, hand: Array[Card]) -> void:
	for upg in spell.upgrades:
		if hand[0].affinity == upg.affinity:
			for effect in upg.effects:
				var instance := effect.new_instance()
				var unit := get_target(effect)
				unit.apply_effect(instance)


func process_effects(unit: Unit, effects: Array[Effect]) -> void:
	for effect in effects:
		if effect is Effect.Burn:
			burn_effect(effect)

		elif effect is Effect.Heal:
			heal_effect(effect)

		elif effect is Effect.Shield:
			shield_effect(effect)

		effect.turns -= 1

		if effect.turns > 0:
			print("%s - %s [%d turns remaining]" % [unit.name, effect.name, effect.turns])
		else:
			print("%s - %s [expired]" % [unit.name, effect.name])

	unit.clear_finished_effects()


func burn_effect(effect: Effect) -> void:
	var targ = get_target(effect)
	targ.take_dmg(effect.dmg)
	total_dmg += effect.dmg
	battle_ui.update_enemy_stats(enemy, total_dmg)


func heal_effect(effect: Effect) -> void:
	var targ = get_target(effect)
	targ.heal(effect.hp)


func shield_effect(effect: Effect) -> void:
	var targ = get_target(effect)
	targ.gain_shield(effect)


func get_target(effect: Effect) -> Unit:
	if effect.target == Effect.Target.PLAYER:
		return player
	else:
		return enemy


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
	Spell.initialize_library()
	Upgrade.initialize_library()
	player.initialize()

	#var analysis = Analysis.new(Spell.get_all_spells(), player.deck)
	#var analysis = Analysis.new([Spell.get_from_id("bolt")], player.deck)
	var analysis = Analysis.new(player.spellbook, player.deck)
	analysis.analyze_spells(player.hand_limit)

	battle_ui.set_select_limit(player.select_limit)
	battle_ui.reset_selected_cards()
	battle_ui.update_display(player, enemy)

	# For now, the battle starts immediately after ready
	start_battle()


func _on_battle_ui_sort_hand(by_value: bool) -> void:
	Analysis.sort_cards(player.hand, by_value)
	battle_ui.update_player_hand(player.hand)


func _on_insta_win_pressed():
	enemy.health = 0
	battle_end()


func _on_escape(dmg: int):
	print("Escape!")
	player.take_dmg(dmg)

	if player.health <= 0:
		game_over()
		return
	
	next_battle()


func _on_reward_level_up_spell(spell: Spell):
	if spell in player.spellbook:
		spell.level_up()
	else:
		player.spellbook.append(spell)

	next_battle()


func _on_reward_upgrade_spell(upg: Upgrade):
	if upg in upg.spell.upgrades:
		upg.level_up()
	else:
		upg.spell.upgrade(upg)

	next_battle()