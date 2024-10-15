extends Node3D

@export var vehicle : BaseCar
@export var hud : CanvasLayer
@export var camera : Camera3D
@export var camera_target : Node3D
@export var snow_particles : CPUParticles3D
@export var engine_sound : AudioStreamPlayer3D

var is_alive = true
var reset_timer : Timer
var double_tap_timer : Timer
var autosave_timer : Timer
var terrain_bonus = 1

var cp_pos : Vector3
var prev_transform : Transform3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	EventBus.car_destroyed.connect(_destroyed)
	EventBus.damagebar_setup.emit(100)

	autosave_timer = Timer.new()
	add_child(autosave_timer)
	autosave_timer.wait_time = 2
	autosave_timer.one_shot = false
	autosave_timer.timeout.connect(_autosave)
	autosave_timer.start()

	reset_timer = Timer.new()
	add_child(reset_timer)
	reset_timer.wait_time = 1
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_reset)

	double_tap_timer = Timer.new()
	add_child(double_tap_timer)
	double_tap_timer.wait_time = 0.5
	double_tap_timer.one_shot = true

	#cp_pos = vehicle.global_position
	#reverter = CReverter.new()
	#reverter.history.max_size = 5
	#reverter.connect_save_load(get_instance_id(), _save_func, _load_func)
	#reverter.commit()
	EventBus.screen_fade_changed.emit(0, 0.2)

func _process(_delta):

	# do 10 damage when pressing G Test
	if Input.is_physical_key_pressed(KEY_G):
		EventBus.car_hit_damage.emit(5)

	if Input.is_action_just_pressed("Restart") && InGameMenuController.current_menu == null:
		if is_alive:
			reset_timer.start()
			EventBus.screen_fade_changed.emit(1, reset_timer.wait_time)
			# double tap to restart
			if !double_tap_timer.is_stopped():
				EventBus.screen_fade_changed.emit(1, 0)
				LevelManager.load_oldest()
			else:
				double_tap_timer.start()

	# stop the timer if the action is released
	if Input.is_action_just_released("Restart"):
		EventBus.screen_fade_changed.emit(0, 0.2)
		reset_timer.stop()

func _destroyed():
	hud.hide()
	is_alive = false
	# Disable this script
	set_process(false)


func _autosave():
	# check if the distance between committed checkpoint and current checkpoint is too small
	if prev_transform.origin.distance_to(vehicle.global_position) > 20:

		LevelManager.commit()
		print("autosave")
		prev_transform = vehicle.global_transform

func _reset():
	LevelManager.load()
