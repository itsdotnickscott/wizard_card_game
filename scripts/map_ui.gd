extends Control


signal location_pressed(location: Location)


func setup_ui(locations: Array[Location]) -> void:
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
