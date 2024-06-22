extends CSGSphere3D

@export var max_heat = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body:Node3D):
	print("body entered heat zone")
	# emit signal when body enters passing the zone position
	EventBus.heat_zone_assigned.emit(max_heat, global_transform.origin)

func _on_area_3d_body_exited(body:Node3D):
	EventBus.heat_zone_removed.emit()
