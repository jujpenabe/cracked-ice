extends Area2D

signal changed

var fill_color := Color(randf(), randf(), randf())


func _draw() -> void:
	var center := Vector2(0, 0)
	var radius := 25.0
	var outline_width := 2.0
	var outline_color := Color(0.0, 0.0, 0.0)
	draw_circle(center, radius, fill_color)
	draw_arc(center, radius, 0, 2 * PI, 100, outline_color, outline_width)


# Call connect_save_load with objects that won't be deleted while
# the reverter is running.
func setup(reverter: CReverter) -> void:
	reverter.connect_save_load(get_instance_id(), save_state, load_state)


func recolor() -> void:
	fill_color = Color(randf(), randf(), randf())
	queue_redraw()


# This is the save function passed into CReverter.connect_save_load().
# The simplest way is to return a Dictionary.
func save_state() -> Dictionary:
	return {
		"position": position,
		"color": fill_color,
	}


# This is the load function passed into CReverter.connect_save_load().
# Use the value returned by the save function to set variables,
# then call whatever updates are necessary.
func load_state(state: Dictionary) -> void:
	position = state.position
	fill_color = state.color
	queue_redraw()
