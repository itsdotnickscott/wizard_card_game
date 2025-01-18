extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()

	tween.tween_property(self, "position", Vector2(position.x + 70, position.y), 1.0)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "modulate", Color(255, 0, 0, 0), 0.25)\
	.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tween.tween_callback(self.queue_free)


func set_damage(val: int):
	text = str(val)
