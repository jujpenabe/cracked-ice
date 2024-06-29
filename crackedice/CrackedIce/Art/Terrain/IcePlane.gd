extends MeshInstance3D

@export var target_temp: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area_3d_area_entered(area:Area3D):
	if area.is_in_group("wheel"):
		EventBus.slip_bonus_changed.emit(0.3)
		EventBus.throtle_bonus_changed.emit(0.5)
		LevelManager.add_heat_bonus("ice", target_temp)

func _on_area_3d_area_exited(area:Area3D):
	if area.is_in_group("wheel"):
		EventBus.slip_bonus_changed.emit(1.0)
		EventBus.throtle_bonus_changed.emit(1.0)
		LevelManager.remove_heat_bonus("ice")
