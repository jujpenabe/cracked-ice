extends Label

var time : float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_center_pivot()

func _center_pivot():
	pivot_offset = size / 2

func _process(delta):
	# Vibrate slightly changing scale to simulate vibration
	if (visible):
		time += delta
		scale.x = sin(time) * 0.01  + 1
		scale.y = sin(time) * 0.01 + 1
