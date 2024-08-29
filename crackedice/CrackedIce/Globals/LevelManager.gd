extends Node

# Dictionary of bonuses
var _heat_bonuses = {}
var _total_heat: float = 0.0
var _changed: bool = false

var initial_temp : float = -50
# Called when the node enters the scene tree for the first time.
func _ready():
	add_heat_bonus("ambient", initial_temp)
	# Ambient temperature + heat bonuses

func restart_level():
	_heat_bonuses.clear()
	_ready()

# func pause_level():
# 	EventBus.game_paused.emit()
# 	get_tree().paused = true

# func resume_level():
# 	# wait 0.2 seconds before unpausing
# 	await get_tree().create_timer(0.2).timeout
# 	get_tree().paused = false
# 	EventBus.game_resumed.emit()

func add_heat_bonus(bonus: String, amount: float):
	_changed = true
	_heat_bonuses[bonus] = amount

func remove_heat_bonus(bonus: String):
	_changed = true
	_heat_bonuses.erase(bonus)

func get_heat_bonus(bonus: String) -> float:
	if _heat_bonuses.has(bonus):
		return _heat_bonuses[bonus]
	return 0

func get_total_heat_bonus() -> float:
	if _changed:
		var total = 0
		for bonus in _heat_bonuses:
			total += _heat_bonuses[bonus]
		_total_heat = total
		_changed = false
	return _total_heat
