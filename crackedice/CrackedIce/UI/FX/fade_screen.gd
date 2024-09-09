extends TextureRect

var t : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.screen_fade_changed.connect(_fade_screen)
	t = create_tween()

func _fade_screen(alpha: float, duration: float) -> void:
	# check if the tween is not null
	if t:
		t.kill()
		t = null

		t = create_tween()
		t.tween_property(self, "modulate:a", alpha, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	else:
		modulate.a = alpha
