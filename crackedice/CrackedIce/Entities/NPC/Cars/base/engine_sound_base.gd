extends AudioStreamPlayer3D

@export var sample_rpm := 4000.0

var vehicle : BaseCar

func _ready():
	vehicle = get_parent()

func _physics_process(delta):
	pitch_scale = vehicle.motor_rpm * (1 - (vehicle.damage * 0.002)) * (1 - (vehicle.current_gear * 0.1)) / sample_rpm
	volume_db = linear_to_db((vehicle.throttle_amount * 0.4) + 0.6)
