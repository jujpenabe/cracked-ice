extends ProgressBar

var sb:StyleBox 
# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.heat_changed.connect(_set_heat)
	
	sb = get_theme_stylebox("fill").duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _set_heat(heat):
	value = heat
	# modulate color based on heat, if heat is 0, modulate is white (1,1,1)
	# modulate in hsv
	modulate = Color.from_hsv(0.65 + (heat / 200) * 0.35, 0.8, 0.8 - (heat / 200) * 0.2)
