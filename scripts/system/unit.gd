class_name Unit extends Node2D


@export var max_health: int = 100

var health: int = max_health
var shields: Array[Effect.Shield] = []
var start_turn_effects: Array[Effect] = []
var end_turn_effects: Array[Effect] = []


func take_dmg(dmg: float) -> void:
	var dmg_left = dmg

	sort_shields_by_turns()
	for shield in shields:
		if dmg_left == 0.0:
			break
		elif dmg_left >= shield.hp:
			dmg_left -= shield.hp
			print("%s - Shield blocks %d damage" % [name, shield.hp])
			print("%s - Shield [expired]" % [name])
			shield.hp = 0.0
			shield.turns = 0
		else:
			shield.hp -= dmg_left
			print("%s - Shield blocks %d damage" % [name, dmg_left])
			dmg_left = 0.0
		
	# Currently just rounding down and ignoring floating value
	health -= int(dmg_left)
	clear_finished_effects()

	print("%s - Takes %d damage" % [name, dmg_left])


func apply_effect(effect: Effect):
	# Shields additionally get added to this array for easy tracking
	# Shields also get added to whatever proc they have to know when the turn tracker goes down
	if effect is Effect.Shield:
		shields.append(effect)

	if effect.proc == Effect.Proc.START_TURN:
		start_turn_effects.append(effect)

	elif effect.proc == Effect.Proc.END_TURN:
		end_turn_effects.append(effect)

	print("%s - Gains %s [%d turns]" % [name, effect.name, effect.turns])


func clear_finished_effects() -> void:
	var active := func(e: Effect) -> bool: return e.turns != 0
	shields = shields.filter(active)
	start_turn_effects = start_turn_effects.filter(active)
	end_turn_effects = end_turn_effects.filter(active)


func heal(hp: float) -> void:
	# Currently just rounding down and ignoring floating value
	health += int(hp)
	if health > max_health:
		health = max_health
	print("%s - Heals for %d HP" % [name, hp])


func gain_shield(shield: Effect.Shield) -> void:
	if not shield in shields:
		shields.append(shield)


func total_shield() -> float:
	var val := 0.0
	for shield in shields:
		val += shield.hp
	return val


func sort_shields_by_turns() -> void:
	var sort := func(a: Effect.Shield, b: Effect.Shield) -> bool:
		return a.turns < b.turns

	shields.sort_custom(sort)


func battle_start() -> void:
	shields = []
	start_turn_effects = []
	end_turn_effects = []