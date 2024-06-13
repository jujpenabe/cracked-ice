extends ProgressBar

var sb:StyleBox 
# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.heat_changed.connect(_set_heat)
	
	sb = get_theme_stylebox("fill").duplicate()

func _set_heat(heat):
	value = heat
	# modulate color based on heat, if heat is 0, modulate is white (1,1,1)
	# modulate in hsv
	modulate = Color.from_hsv(1, (1000 + (heat * abs(heat))) / 4000, 1)
