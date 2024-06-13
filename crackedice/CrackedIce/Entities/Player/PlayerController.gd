extends Node3D

@export var vehicle : BaseCar
@export var heat: int = 0

var is_alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	EventBus.damagebar_setup.emit(100)
	EventBus.car_destroyed.connect(_destroyed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Hud/speed.text= str(round(vehicle.speed * 1.8))

	# do 10 damage when pressing g
	if Input.is_physical_key_pressed(KEY_G):
		EventBus.car_hit_damage.emit(5)

	if Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func _destroyed():
	if is_alive:
		is_alive = false
		await get_tree().create_timer(4.4).timeout
		get_tree().reload_current_scene()
	else:
		pass

