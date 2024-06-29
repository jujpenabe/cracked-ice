extends Label

var temp : float = 0
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_process_heat(delta)

func _process_heat(delta : float):
	temp = lerp(temp, LevelManager.get_total_heat_bonus(), delta * 0.5)
	text = str(roundi(temp)) + "°"
