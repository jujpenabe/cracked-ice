extends Camera3D


@export var target_distance: float = 5.0
@export var target_height: float = 2.0
@export var speed:=20.0
@export var freecam3d:= Freecam3D.new()
@export var normal_fov:= 90.0
@export var throtle_in_fov:= 105.0
@export var fov_change_speed:= 2.0

var follow_this = null
var last_lookat
var is_throthle_in = false

var timer

func _ready():
	follow_this = get_parent()
	last_lookat = follow_this.global_transform.origin
	EventBus.throtle_in.connect(_on_throtle_in)
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.one_shot = true
	timer.timeout.connect(_throttle_out)
	timer.start()

func _physics_process(delta):
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_pos = global_transform.origin
	
	# ignore y
	delta_v.y = 0.0
	
	if (delta_v.length() > target_distance):
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_transform.origin + delta_v
	else:
		target_pos.y = follow_this.global_transform.origin.y + target_height
	
	global_transform.origin = global_transform.origin.lerp(target_pos, delta * speed)
	
	last_lookat = last_lookat.lerp(follow_this.global_transform.origin, delta * speed)
	
	look_at(last_lookat, Vector3.UP)

	if Input.is_action_just_pressed("switch_camera"):
		freecam3d.make_current()

	if is_throthle_in:
		# lerp fov to desired value
		fov = lerp(fov, throtle_in_fov, delta * fov_change_speed)
	else:
		fov = lerp(fov, normal_fov, delta * fov_change_speed)

func _on_throtle_in():
	is_throthle_in = true
	timer.start()

func _throttle_out():
	is_throthle_in = false