extends MeshInstance3D

# Simple y-rotation performant script
@export var speed := 0.5
@export var enabled := true

func _process(delta):
	if enabled:
		rotate_y(-speed * delta)
	else:
		# disable processing
		set_process(false)