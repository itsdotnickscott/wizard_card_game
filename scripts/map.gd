class_name Map extends Node


@onready var battle: Battle = get_node("Battle")
@onready var player: Player = get_node("Player")
@onready var map_ui: Control = get_node("MapUI")
@onready var reward_ui: Control = get_node("RewardUI")
@onready var defeat_ui: Control = get_node("DefeatUI")


var locations: Array[Location] = []
var curr_location: Location
var stage: int = 1


func create_stage() -> void:
	var start := Location.Fight.new(
		EnemyInfo.new("Practice Dummy", Enemy.Tier.NORMAL, 100, [Attack.new("Stay Still", 0)]), 
		[Reward.Type.CHOOSE_IDOL, Reward.Type.CARD_PACK], 
	)
	var choice1 := Location.Fight.new(
		EnemyInfo.new("Wild Deer", Enemy.Tier.NORMAL, 175, [Attack.new("Prance", 10)]), 
		[Reward.Type.TOME, Reward.Type.CARD_PACK],
	)
	var choice2 := Location.Fight.new(
		EnemyInfo.new("Wild Skunk", Enemy.Tier.NORMAL, 150, [Attack.new("Spray", 15)]), 
		[Reward.Type.TOME, Reward.Type.CARD_PACK],
	) 
	var choice1a := Location.Fight.new(
		EnemyInfo.new("Wild Bear", Enemy.Tier.NORMAL, 300, [Attack.new("Claw", 20)]), 
		[Reward.Type.TAROT_PACK, Reward.Type.CARD_PACK], 
	) 
	var choice1b := Location.Fight.new(
		EnemyInfo.new("Wild Wolf", Enemy.Tier.NORMAL, 275, [Attack.new("Pounce", 25)]), 
		[Reward.Type.TAROT_PACK, Reward.Type.CARD_PACK],
	) 
	var choice2a := Location.Fight.new(
		EnemyInfo.new("Wild Crocodile", Enemy.Tier.NORMAL, 300, [Attack.new("Crunch", 20)]),
		[Reward.Type.TAROT_PACK, Reward.Type.CARD_PACK],
	) 
	var choice2b := Location.Fight.new(
		EnemyInfo.new("Wild Snake", Enemy.Tier.NORMAL, 275, [Attack.new("Bite", 25)]), 
		[Reward.Type.TAROT_PACK, Reward.Type.CARD_PACK],
	) 
	var shop := Location.Market.new()
	var boss := Location.Fight.new(
		EnemyInfo.new("Metal Guard", Enemy.Tier.BOSS, 500, [Attack.new("Sword and Shield", 60)]),
		[Reward.Type.CHOOSE_IDOL, Reward.Type.CARD_PACK],
	)

	start.set_links([choice1, choice2])
	choice1.set_links([choice1a, choice1b])
	choice2.set_links([choice2a, choice2b])
	choice1a.set_links([shop])
	choice1b.set_links([shop])
	choice2a.set_links([shop])
	choice2b.set_links([shop])
	shop.set_links([boss])

	locations = [start, choice1, choice2, choice1a, choice1b, choice2a, choice2b, shop, boss]


func _ready() -> void:
	Spell.init_library()
	Idol.init_library()
	Tarot.init_library()
	
	player.init()
	battle.init(player)

	#var analysis = Analysis.new(Spell.get_all_spells(), player.deck)
	#var analysis = Analysis.new([Spell.get_from_id("bolt")], player.deck)
	var analysis = Analysis.new(player.spellbook, player.deck)
	analysis.analyze_spells(player.hand_limit)

	create_stage()
	map_ui.setup_ui(locations)
	curr_location = locations[0]
	map_ui.update_location(curr_location)

	battle.start(curr_location.enemy)


func _on_location_pressed(location: Location) -> void:
	map_ui.visible = false
	curr_location = location
	battle.visible = true
	battle.start(curr_location.enemy)


func _on_gain_reward(choice: Variant) -> void:
	if choice is Spell:
		if choice in player.spellbook:
			choice.level_up()
		else:
			player.spellbook.append(choice)

	elif choice is Card:
		player.deck.append(choice)

	elif choice is Tarot:
		player.tarots.append(choice)

	elif choice is Idol:
		player.gain_idol(choice)

	reward_ui.next_reward()


func _on_next_location() -> void:
	reward_ui.visible = false
	map_ui.update_location(curr_location)
	map_ui.visible = true


func _on_battle_player_lose():
	battle.visible = false
	defeat_ui.visible = true


func _on_battle_player_win():
	battle.visible = false
	reward_ui.set_rewards(curr_location, player)
	reward_ui.visible = true
