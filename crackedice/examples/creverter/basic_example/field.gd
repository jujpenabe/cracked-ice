extends Node2D

@onready var balls: Array = [$Ball1, $Ball2, $Ball3]
var dragged_ball: Area2D = null


func _ready() -> void:
	for ball in balls:
		ball.input_event.connect(_on_ball_input_event.bind(ball))


# Keep passing the reverter down to objects that won't be deleted
# while the reverter is running.
func setup(reverter: CReverter) -> void:
	for ball in balls:
		ball.setup(reverter)


func _on_ball_input_event(
		_viewport: Node, event: InputEvent, _shape_idx: int, ball: Area2D
) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			ball.recolor()
			ball.position = event.position
			ball.changed.emit()
			dragged_ball = ball


func _input(event: InputEvent) -> void:
	if dragged_ball != null:
		if event is InputEventMouseMotion:
			dragged_ball.position = event.position
		elif event is InputEventMouseButton and not event.pressed:
			dragged_ball = null
