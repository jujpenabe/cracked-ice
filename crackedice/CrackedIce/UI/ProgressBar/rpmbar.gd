extends TextureProgressBar

var sb = StyleBoxFlat.new()
var rpm: float = 0 : set = _set_rpm, get = _get_rpm
var tween: Tween

func _set_rpm(_new_rpm):
	rpm = min(max_value, _new_rpm)
	value = rpm
	# change color exponentially from yellow to red
	sb.bg_color = Color.from_hsv(0.15 - (rpm / max_value) * 0.2, 0.9, 0.9 - (rpm / max_value) * 0.2)

func _get_rpm():
	return rpm

func _set_gear(_new_gear: String):
	$Gear.text = " " +_new_gear

func _set_rpm_max(_new_rpm_max):
	max_value = _new_rpm_max * 0.8

func _get_rpm_max():
	return max_value

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.max_rpm_changed.connect(_set_rpm_max)
	EventBus.rpm_changed.connect(_set_rpm)
	EventBus.gear_changed.connect(_set_gear)
	EventBus.throtle_in.connect(_throttle_in)
	EventBus.throtle_out.connect(_throttle_out)
	EventBus.max_rpm_requested.emit()

	add_theme_stylebox_override("fill", sb)

func _throttle_in():
	# stop the tween
	if tween:
		tween.stop()
	# Modulate the alpha to 1 in 0.2 seconds
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, 0.2)
	tween.play()

func _throttle_out():
	# stop the tween
	if tween:
		tween.stop()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.6, 2)
	tween.play()


