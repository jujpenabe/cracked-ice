extends RigidBody3D

signal destroyed()

var destroyable : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	# wait 2 seconds and enable can be destroyed
	await get_tree().create_timer(2.0).timeout
	set_physics_process(true)

func _physics_process(delta):
	if !sleeping:
		if abs(angular_velocity.x + angular_velocity.y + angular_velocity.z) > 0.9:
			destroyable = true
			$Timer.stop()

func _on_sleeping_state_changed():
	if sleeping and destroyable:
		destroyed.emit()
		$Timer.start()


func _on_timer_timeout():
	destroyable = false
	# duplicate the surface material
	var alpha_mat: BaseMaterial3D = $Mesh.get_active_material(0).duplicate()
	$Mesh.set_surface_override_material(0, alpha_mat)
	alpha_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Tween the transparency in 2 seconds
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(alpha_mat, "albedo_color", Color(1.0, 0.0, 0.0, 0.0), 2.0)
	# destroy the object after tween is done
	tween.finished.connect(func(): queue_free())
