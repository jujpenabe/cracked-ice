extends Node3D

@export var max_heat = 100
@export var columns : int = 3
@export var min_cols : int = 2
# Called when the node enters the scene tree for the first time.

var destroyed := false

func _on_area_3d_body_entered(body:Node3D):
	if columns >= min_cols:
		EventBus.heat_zone_assigned.emit(max_heat, global_transform.origin)

func _on_area_3d_body_exited(body:Node3D):
	EventBus.heat_zone_removed.emit()


func _on_heater_column_destroyed():
	columns -= 1
	if columns < min_cols and !destroyed:
		_destroy_heater()


func _destroy_heater():
	destroyed = true
	%HeaterTop.freeze = false
		# add to collision layer
	%HeaterTop.set_collision_layer_value(3, true)
	%HeaterBase.enabled = false

	var alpha_mat: BaseMaterial3D = %HeaterTopMesh.get_active_material(0).duplicate()
	var dark_mat: BaseMaterial3D = %HeaterBase.get_active_material(0).duplicate()
	%HeaterTopMesh.set_surface_override_material(0, alpha_mat)
	%HeaterBase.set_surface_override_material(0, dark_mat)
	alpha_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Tween the transparency in 2 seconds
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT).set_parallel(true)
	tween.tween_property(alpha_mat, "albedo_color", Color(0.3, 0.2, 0.2, 1.0), 4.0)
	# wait until the tween is finished and start another one
	tween.tween_property(dark_mat, "albedo_color:v", 0.44, 4.0)
	await tween.finished
	await get_tree().create_timer(4.0).timeout
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(alpha_mat, "albedo_color", Color(0.0, 0.0, 0.2, 0.0), 4.0)


	# wait until the tween is finished and destroy the node
	await tween.finished
	# destroy the heater top if it exists
	EventBus.heat_zone_removed.emit()
	%HeaterTop.queue_free()

