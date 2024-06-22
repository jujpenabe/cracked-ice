extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.heat_changed.connect(_heat_changed)


func _heat_changed(new_heat):
	# change modulate based on heat
	if new_heat < 0:
		modulate = Color(1, 1, 1, pow(new_heat, 2) / 20000)
	else:
		modulate = Color(1, 1, 1, 0)