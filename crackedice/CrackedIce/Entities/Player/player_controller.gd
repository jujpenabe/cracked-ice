extends Node3D

@export var vehicle : BaseCar
@export var hud : CanvasLayer
@export var camera : Camera3D
@export var camera_target : Node3D
@export var snow_particles : GPUParticles3D
@export var engine_sound : AudioStreamPlayer3D

var is_alive = true
var reset_timer : Timer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	EventBus.car_destroyed.connect(_destroyed)
	EventBus.damagebar_setup.emit(100)

	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.wait_time = 0.2
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_reset)


func _process(_delta):


	# do 10 damage when pressing g
	if Input.is_physical_key_pressed(KEY_G):
		EventBus.car_hit_damage.emit(5)

	if Input.is_action_just_pressed("Restart"):
		if is_alive:
			reset_timer.start()

	# stop the timer if the action is released
	if Input.is_action_just_released("Restart"):
		reset_timer.stop()

func _destroyed():
	hud.hide()
	is_alive = false

# func _pause():
# 	LevelManager.pause_level()

func _reset():
	SceneLoader.reload_current_scene()

