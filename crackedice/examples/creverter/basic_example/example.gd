extends Node

const MAX_ITEMS: int = 20
var reverter: CReverter

# This is a typical setup for the CReverter.
# Set its max size and pass it into subsystems you want to track.
func _ready() -> void:
	reverter = CReverter.new()
	reverter.history.max_size = MAX_ITEMS
	$Field.setup(reverter)
	$ControlBoard.setup(reverter)
