extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.speed_changed.connect(_on_speed_changed)

func _on_speed_changed(speed):
	text = str(speed)
