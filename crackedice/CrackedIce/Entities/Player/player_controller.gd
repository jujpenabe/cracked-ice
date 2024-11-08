extends Node3D

@export var vehicle : BaseCar
@export var hud : CanvasLayer
@export var camera : Camera3D
@export var camera_target : Node3D
@export var snow_particles : CPUParticles3D
@export var engine_sound : AudioStreamPlayer3D

var is_alive = true
var load_saved_timer : Timer
var load_oldest_reverter_timer : Timer
var double_tap_timer : Timer
var autosave_timer : Timer
var out_of_combat_timer : Timer
var terrain_bonus = 1

var cp_pos : Vector3
var prev_transform : Transform3D



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	EventBus.car_destroyed.connect(_destroyed)
	EventBus.damagebar_setup.emit(100)

	_autosave()
	autosave_timer = Timer.new()
	add_child(autosave_timer)
	autosave_timer.wait_time = 2
	autosave_timer.one_shot = false
	autosave_timer.timeout.connect(_autosave)
	autosave_timer.start()

	load_saved_timer = Timer.new()
	add_child(load_saved_timer)
	load_saved_timer.wait_time = 1
	load_saved_timer.one_shot = true
	load_saved_timer.timeout.connect(LevelManager.load)

	load_oldest_reverter_timer = Timer.new()
	add_child(load_oldest_reverter_timer)
	load_oldest_reverter_timer.wait_time = 0.2
	load_oldest_reverter_timer.one_shot = true
	load_oldest_reverter_timer.timeout.connect(LevelManager.load_oldest)

	double_tap_timer = Timer.new()
	add_child(double_tap_timer)
	double_tap_timer.wait_time = 0.5
	double_tap_timer.one_shot = true

	out_of_combat_timer = Timer.new()
	add_child(out_of_combat_timer)
	out_of_combat_timer.wait_time = 4.4
	out_of_combat_timer.one_shot = true
	out_of_combat_timer.timeout.connect(_on_out_of_combat_timer_timeout)
	out_of_combat_timer.start()
	EventBus.car_hit_damage.connect(out_of_combat_timer.start)

	#cp_pos = vehicle.global_position
	#reverter = CReverter.new()
	#reverter.history.max_size = 5
	#reverter.connect_save_load(get_instance_id(), _save_func, _load_func)
	#reverter.commit()

func _process(_delta):

	# do 10 damage when pressing G Test
	if Input.is_physical_key_pressed(KEY_G):
		EventBus.car_hit_damage.emit(5)

	if Input.is_action_just_pressed("Restart") && InGameMenuController.current_menu == null:
		if is_alive:
			load_saved_timer.start()
			EventBus.screen_fade_changed.emit(1, load_saved_timer.wait_time)
			# double tap to restart
			if !double_tap_timer.is_stopped():
				EventBus.screen_fade_changed.emit(0.9, load_oldest_reverter_timer.wait_time * 0.5)
				load_oldest_reverter_timer.start()
			else:
				double_tap_timer.start()

	# stop the timer if the action is released
	if Input.is_action_just_released("Restart") && load_oldest_reverter_timer.is_stopped():
		EventBus.screen_fade_changed.emit(0, 0.2)
		load_saved_timer.stop()

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

func _on_out_of_combat_timer_timeout():
	print("out of combat")
	EventBus.out_of_combat.emit()