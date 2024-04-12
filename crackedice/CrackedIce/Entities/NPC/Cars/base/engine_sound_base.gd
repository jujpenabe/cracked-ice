extends AudioStreamPlayer3D

@export var vehicle : BaseCar
@export var sample_rpm := 4000.0

func _physics_process(delta):
	pitch_scale = vehicle.motor_rpm * 0.7 / sample_rpm
	volume_db = linear_to_db((pow(vehicle.throttle_amount, 2) * 0.25) + 0.5) # max value is expected at 0.75
