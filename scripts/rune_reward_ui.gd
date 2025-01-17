extends Control


@onready var table_w_main: Control = get_node("RuneTable/WithMain")
@onready var main_panel: Panel = get_node("RuneTable/WithMain/MainCard")
@onready var w_main_c1_panel: Panel = get_node("RuneTable/WithMain/Card1")
@onready var w_main_c2_panel: Panel = get_node("RuneTable/WithMain/Card2")
@onready var w_main_c3_panel: Panel = get_node("RuneTable/WithMain/Card3")
@onready var w_main_card_panels: Array[Panel] = [w_main_c1_panel, w_main_c2_panel, w_main_c3_panel]

@onready var table_no_main: Control = get_node("RuneTable/NoMain")
@onready var no_main_c1_panel: Panel = get_node("RuneTable/NoMain/Card1")
@onready var no_main_c2_panel: Panel = get_node("RuneTable/NoMain/Card2")
@onready var no_main_c3_panel: Panel = get_node("RuneTable/NoMain/Card3")
@onready var no_main_card_panels: Array[Panel] = [no_main_c1_panel, no_main_c2_panel, no_main_c3_panel]


func _reset_choices():
	for panel in ([main_panel] + w_main_card_panels + no_main_card_panels):
		panel.get_child(0).queue_free()


func set_choices(reward: Reward):
	pass