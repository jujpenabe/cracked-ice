extends MeshInstance3D

# Simple y-rotation performant script
@export var speed := 0.5
@export var enabled := true

var visible_on_screen := false

func _process(delta):
	if enabled && visible_on_screen:
		rotate_y(-speed * delta)
	else:
		# disable processing
		set_process(false)

func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	visible_on_screen = true


func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	visible_on_screen = false
