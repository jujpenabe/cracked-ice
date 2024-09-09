extends Panel

var reverter: CReverter
@onready var _save_buttons: Array = [
	%SaveButton1,
	%SaveButton2,
	%SaveButton3,
	%SaveButton4,
	%SaveButton5,
	%SaveButton6,
	%SaveButton7,
	%SaveButton8,
	%SaveButton9,
]
@onready var _load_buttons: Array = [
	%LoadButton1,
	%LoadButton2,
	%LoadButton3,
	%LoadButton4,
	%LoadButton5,
	%LoadButton6,
	%LoadButton7,
	%LoadButton8,
	%LoadButton9,
]

func setup(p_reverter: CReverter) -> void:
	reverter = p_reverter
	%Diagram.setup(reverter)

	# Give the reverter an interface by connecting its methods to signals.
	%CommitButton.pressed.connect(reverter.commit)
	%RevertButton.pressed.connect(reverter.revert)
	%UndoButton.pressed.connect(reverter.undo)
	%RedoButton.pressed.connect(reverter.redo)
	%LoadOldestButton.pressed.connect(reverter.load_oldest)
	%LoadNewestButton.pressed.connect(reverter.load_newest)
	%ClearButton.pressed.connect(_on_clear_pressed)
	for i in range(9):
		_save_buttons[i].pressed.connect(reverter.commit.bind(str(i + 1)))
		_save_buttons[i].pressed.connect(_on_save_or_load)
	for i in range(9):
		_load_buttons[i].pressed.connect(reverter.load_tag.bind(str(i + 1)))

	reverter.saved.connect(_on_save_or_load)
	reverter.loaded.connect(_on_save_or_load)
	for ball in %Field.balls:
		ball.changed.connect(_on_ball_changed)

	_update_board()


# For more complicated interfaces, connect your own methods and call
# the reverter's methods from there.
func _on_ball_changed() -> void:
	%CommitButton.disabled = false
	%RevertButton.disabled = reverter.history.is_empty()


func _on_save_or_load() -> void:
	_update_board()


# Access the history to clear things while the reverter is running.
func _on_clear_pressed() -> void:
	reverter.history.clear()
	_update_board()


func _update_board() -> void:
	%CommitButton.disabled = not reverter.history.is_empty()
	%RevertButton.disabled = true
	%UndoButton.disabled = not reverter.is_undo_possible()
	%RedoButton.disabled = not reverter.is_redo_possible()
	%LoadOldestButton.disabled = reverter.history.is_empty()
	%LoadNewestButton.disabled = reverter.history.is_empty()
	%ClearButton.disabled = reverter.history.is_empty()
	for i in range(9):
		_load_buttons[i].disabled = not reverter.history.has_tag(str(i + 1))

	%Diagram.queue_redraw()
