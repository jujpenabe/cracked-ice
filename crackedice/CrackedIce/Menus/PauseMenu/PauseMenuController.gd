class_name PauseMenuController
extends Node
## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene

var pause_timer : Timer

func _input(event):
	if event.is_action_pressed("Pause") :
		pause_timer.start()

	if event.is_action_released("Pause") :
		pause_timer.stop()

	# if event.is_action_pressed("ui_cancel"): # TODO: ui_cancel is not working
	# 	print("ui_cancel")

func _ready():
	InGameMenuController.scene_tree = get_tree()
	pause_timer = Timer.new()
	add_child(pause_timer)
	pause_timer.wait_time = 0.2
	pause_timer.one_shot = true
	pause_timer.timeout.connect(_on_pause_timer_timeout)

func _on_pause_timer_timeout():
	InGameMenuController.open_menu(pause_menu_packed, get_viewport())
