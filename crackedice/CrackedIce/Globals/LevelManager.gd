extends Node


## PLAYER 1 STATS (Move to player_controller.gd)
# Dictionary of bonuses
var _heat_bonuses = {}
var _total_heat: float = 0.0
var _changed: bool = false

var _reverter


var initial_temp : float = -50
# Called when the node enters the scene tree for the first time.
func _ready():

	add_heat_bonus("ambient", initial_temp)
	_reverter = CReverter.new()
	_reverter.history.max_size = 5
	_reverter.connect_save_load(get_instance_id(), _save, _load)
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

func _save() -> Dictionary:
	var scene = get_tree().current_scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	return {
		"game": packed_scene,
	}

func save(path: String = "saved_game"):
	var scene = get_tree().current_scene
	# print root node
	print(scene)
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)

	var save_path = "user://" + path + ".scn"
	var error = ResourceSaver.save(packed_scene, save_path)

	if error == OK:
		print("Game saved at: " + save_path)
	else:
		print("Error saving game: " + error)

func _load(memento):
	get_tree().change_scene_to_packed(memento.game)

func load(path: String = "saved_game"):
	# dont load if no the game is paused
	if get_tree().paused:
		return
	var load_path = "user://" + path + ".scn"

	if FileAccess.file_exists(load_path):
		var loaded_scene = ResourceLoader.load(load_path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded_scene is PackedScene:
			var error = get_tree().change_scene_to_packed(loaded_scene)
			if error == OK:
				print("Game loaded from: " + load_path)
				# clear the reverter
				_reverter.history.clear()
			else:
				print("Error loading game: " + str(error))
		else:
			print("The file loaded is not a valid PackedScene.")
	else:
		print("No game saved at: " + load_path)

func commit():
	_reverter.commit()

func load_oldest():
	_reverter.load_oldest()