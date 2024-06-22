extends Node3D

@export var vehicle : BaseCar
@export var hud : CanvasLayer
@export var packedSceneToSpawn : PackedScene
@export var camera : Camera3D
@export var camera_target : Node3D
@export var snow_particles : GPUParticles3D
@export var engine_sound : AudioStreamPlayer3D

var is_alive = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	EventBus.car_destroyed.connect(_destroyed)
	EventBus.damagebar_setup.emit(100)

func _process(delta):
	

	# do 10 damage when pressing g
	if Input.is_physical_key_pressed(KEY_G):
		EventBus.car_hit_damage.emit(5)

	if Input.is_action_just_pressed("Restart"):
		if is_alive:
			# wait 0.2 second and reload the current scene
			await get_tree().create_timer(0.2).timeout
			vehicle.destroy()

func _destroyed():
	hud.hide()	
	is_alive = false

