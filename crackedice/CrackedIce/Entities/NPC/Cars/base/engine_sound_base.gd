extends AudioStreamPlayer3D

@export var vehicle : BaseCar
@export var sample_rpm := 4000.0

func _physics_process(delta):
	pitch_scale = vehicle.motor_rpm * 0.7 / sample_rpm
	volume_db = linear_to_db((vehicle.throttle_amount * 0.4) + 0.6)
