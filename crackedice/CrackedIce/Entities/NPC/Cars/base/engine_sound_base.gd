extends AudioStreamPlayer3D

@export var sample_rpm := 4000.0

var vehicle : BaseCar

func _ready():
	vehicle = get_parent()
	EventBus.rpm_changed.connect(_play_engine_sound)
	EventBus.car_destroyed.connect(_stop)
	# play engine sound

func _play_engine_sound(_motor_rpm : float):
	pitch_scale = _motor_rpm * (1 - (vehicle.damage * 0.002)) * (1 - (vehicle.current_gear * 0.1)) / sample_rpm
	volume_db = linear_to_db((vehicle.throttle_amount * 0.3) + 0.7 - (vehicle.damage * 0.002))

func _stop():
	# disconnect engine sound
	EventBus.engine_started.disconnect(_play_engine_sound)
	var pitch_tween = get_tree().create_tween()
	pitch_tween.tween_property(self, "pitch_scale", 0.8, 3)
	var vol_tween = get_tree().create_tween()
	vol_tween.tween_property(self, "volume_db", linear_to_db(0.1), 6)