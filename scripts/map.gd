class_name Map extends Control


signal location_pressed(location: Location)


@onready var location_button = preload("res://scenes/location_button.tscn")


var locations: Array[Location] = []
var stage: int = 1


func create_stage() -> void:
	var start := Location.Battle.new(
		EnemyInfo.new("Practice Dummy", Enemy.Tier.NORMAL, 100, [Attack.new("Stay Still", 0)]), 
		Reward.get_random_reward()
	)
	var choice1 := Location.Battle.new(
		EnemyInfo.new("Wild Deer", Enemy.Tier.NORMAL, 175, [Attack.new("Prance", 5)]), 
		Reward.get_random_reward()
	)
	var choice2 := Location.Battle.new(
		EnemyInfo.new("Wild Skunk", Enemy.Tier.NORMAL, 150, [Attack.new("Spray", 10)]), 
		Reward.get_random_reward()
	) 
	var choice1a := Location.Battle.new(
		EnemyInfo.new("Wild Bear", Enemy.Tier.NORMAL, 250, [Attack.new("Claw", 15)]), 
		Reward.get_random_reward()
	) 
	var choice1b := Location.Battle.new(
		EnemyInfo.new("Wild Wolf", Enemy.Tier.NORMAL, 225, [Attack.new("Pounce", 20)]), 
		Reward.get_random_reward()
	) 
	var choice2a := Location.Battle.new(
		EnemyInfo.new("Wild Crocodile", Enemy.Tier.NORMAL, 250, [Attack.new("Crunch", 15)]),
		Reward.get_random_reward()
	) 
	var choice2b := Location.Battle.new(
		EnemyInfo.new("Wild Snake", Enemy.Tier.NORMAL, 225, [Attack.new("Bite", 20)]), 
		Reward.get_random_reward()
	) 
	var shop := Location.Market.new()
	var boss := Location.Battle.new(
		EnemyInfo.new("Metal Guard", Enemy.Tier.BOSS, 300, [Attack.new("Sword and Shield", 30)]),
		Reward.get_random_reward()
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
		
		if location == next:
			curr_lvl += 1
			hbox = vbox.get_children()[curr_lvl]
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			next = null

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

					if next == null:
						next = link


func add_location(location: Location, hbox: HBoxContainer) -> void:
	var button = location_button.instantiate()
	button.location = location
	hbox.add_child(button)
	button.pressed.connect(_on_location_pressed.bind(location))


func update_location(current: Location) -> void:
	for hbox in get_node("Panel/VBoxContainer").get_children():
		for button in hbox.get_children():
			if button.location == current:
				button.reveal_location_name()
				button.disabled = true
				button.set_current(true)

			elif button.location in current.links:
				button.reveal_location_name()
				button.disabled = false
				button.set_current(false)

			else:
				button.disabled = true
				button.set_current(false)


func _on_location_pressed(location: Location):
	location_pressed.emit(location)
