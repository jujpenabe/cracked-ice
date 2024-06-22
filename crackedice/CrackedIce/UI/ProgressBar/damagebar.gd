extends ProgressBar

@onready var timer = $Timer
@onready var hit_bar = $HitBar

var health: float = 0 : set = _set_health, get = _get_health
var hit_health = 0 : set = _set_hit_health
var damage_amount: float = 0
var damaged = false

func _set_health(_new_health):
	health = min(max_value, _new_health)
	value = health

	if health >= 100 && damaged:
		damaged = false
		EventBus.car_destroyed.emit()

func _get_health():
	return health

func _set_hit_health(_new_hit_health):
	var prev_hit_health = hit_health
	hit_health = min(hit_bar.max_value, _new_hit_health)
	hit_bar.value = hit_health

	if hit_health > prev_hit_health:
		timer.start()
	else:
		hit_bar.value = hit_health

func _setup(_max_health):
	health = 0
	max_value = _max_health
	value = health
	hit_bar.max_value = _max_health
	hit_bar.value = health

func _set_hit_damage(_value):
	hit_health += _value

func _ready():
	EventBus.damagebar_hit_health_changed.connect(_set_hit_health)
	EventBus.damagebar_setup.connect(_setup)
	EventBus.car_hit_damage.connect(_set_hit_damage)

func _process(delta):
	if damaged:
		health += damage_amount
		EventBus.damage_made.emit(damage_amount)
		if health >= hit_health:
			health = hit_health
			damaged = false
		value = health

func _on_timer_timeout():
	damaged = true
	# damage amount fraction to add every frame so it completes in 1 second
	damage_amount = (hit_health - health) / 30
