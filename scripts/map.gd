class_name Map extends Control


signal location_pressed(location: Location)


@onready var location_scene := preload("res://scenes/location.tscn")


var locations: Array[Location] = []
var stage: int = 1


func create_stage() -> void:
	var start: Location = location_scene.instantiate()
	var choice1: Location = location_scene.instantiate()
	var choice2: Location = location_scene.instantiate()
	var choice1a: Location = location_scene.instantiate()
	var choice1b: Location = location_scene.instantiate()
	var choice2a: Location = location_scene.instantiate()
	var choice2b: Location = location_scene.instantiate()
	var shop: Location = location_scene.instantiate()
	var boss: Location = location_scene.instantiate()

	start.init_as_fight(
		EnemyInfo.new("Practice Dummy", Enemy.Tier.NORMAL, 75, [Attack.new("Stay Still", 0)]), 
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], [choice1, choice2]
	)
	choice1.init_as_fight(
		EnemyInfo.new("Wild Deer", Enemy.Tier.NORMAL, 125, [Attack.new("Prance", 5)]), 
		[Reward.TarotPack.get_random(), Reward.CardPack.get_random()], [choice1a, choice1b]
	)
	choice2.init_as_fight(
		EnemyInfo.new("Wild Skunk", Enemy.Tier.NORMAL, 100, [Attack.new("Spray", 10)]), 
		[Reward.TarotPack.get_random(), Reward.CardPack.get_random()], [choice2a, choice2b]
	) 
	choice1a.init_as_fight(
		EnemyInfo.new("Wild Bear", Enemy.Tier.NORMAL, 175, [Attack.new("Claw", 15)]), 
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], [shop]
	) 
	choice1b.init_as_fight(
		EnemyInfo.new("Wild Wolf", Enemy.Tier.NORMAL, 150, [Attack.new("Pounce", 20)]), 
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], [shop]
	) 
	choice2a.init_as_fight(
		EnemyInfo.new("Wild Crocodile", Enemy.Tier.NORMAL, 175, [Attack.new("Crunch", 15)]),
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], [shop]
	) 
	choice2b.init_as_fight(
		EnemyInfo.new("Wild Snake", Enemy.Tier.NORMAL, 150, [Attack.new("Bite", 20)]), 
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], [shop]
	) 
	shop.init_as_market([boss])
	boss.init_as_fight(
		EnemyInfo.new("Metal Guard", Enemy.Tier.BOSS, 300, [Attack.new("Sword and Shield", 30)]),
		[Reward.Tome.get_random(), Reward.CardPack.get_random()], []
	)

	locations = [start, choice1, choice2, choice1a, choice1b, choice2a, choice2b, shop, boss]


func setup_ui() -> void:
	var placed := []
	var curr_lvl := -1
	var vbox := get_node("Panel/VBoxContainer")

	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	var next := locations[0]

	for location in locations:
		if not location in placed:
			add_location(location, hbox)
			placed.append(location)
		
		# Creates the next tier of locations if finished with current level
		if location == next:
			curr_lvl += 1
			hbox = vbox.get_children()[curr_lvl]
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			next = null

		# Establishes links onto the board, one level up
		if location.links.size() > 0:
			var new_hbox: HBoxContainer = null

			if vbox.get_children().size() > curr_lvl + 1:
				new_hbox = vbox.get_children()[curr_lvl + 1]
			else:
				new_hbox = HBoxContainer.new()
				vbox.add_child(new_hbox)
				
			for link in location.links:
				if not link in placed:
					add_location(link, new_hbox)
					placed.append(link)

					# Signifies when we are moving up a level
					if next == null:
						next = link


func add_location(location: Location, hbox: HBoxContainer) -> void:
	hbox.add_child(location)
	location.get_node("Button").pressed.connect(_on_location_pressed.bind(location))


func update_location(current: Location) -> void:
	for hbox in get_node("Panel/VBoxContainer").get_children():
		for location in hbox.get_children():
			if location == current:
				location.reveal_name()
				location.set_disabled(true)
				location.set_current(true)

			elif location in current.links:
				location.reveal_name()
				location.set_disabled(false)
				location.set_current(false)

			else:
				location.set_disabled(true)
				location.set_current(false)


func _on_location_pressed(location: Location) -> void:
	location_pressed.emit(location)
