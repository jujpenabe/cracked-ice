extends CanvasLayer

@export_file("*.tscn") var main_menu_scene : String

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $ConfirmExit.visible:
			$ConfirmExit.hide()
		elif $ConfirmMainMenu.visible:
			$ConfirmMainMenu.hide()
		get_viewport().set_input_as_handled()
	# if physical key R is pressed 
	if event.is_action_pressed("Restart"):
		if visible and !%OptionsPanel.visible:
			_restart()

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.car_destroyed.connect(_destroyed)
	if OS.has_feature("web"):
		%ExitButton.hide()
	_setup_main_menu()

func _setup_main_menu():
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()
	%RestartButton.grab_focus()

func _destroyed():
	show()
	# tween modulate for two seconds the %BackgroundTextureRect
	var tween = get_tree().create_tween()
	tween.tween_property(%BackgroundTextureRect, "modulate", Color(1, 1, 1, 1), 6)
	# timer timeout 2 seconds and show the %Panel
	await get_tree().create_timer(4).timeout
	%BackgroundColor.show()
	var tween2 = get_tree().create_tween()
	tween2.tween_property(%BackgroundColor, "color", Color(1, 0.9,0.9, 0.9), 6)
	%OptionsPanel.show()
	# grab focus the restart button
	%RestartButton.grab_focus()

func _on_exit_button_pressed():
	%ExitButton.grab_focus()
	$ConfirmExit.popup_centered()

func _on_main_menu_button_pressed():
	%MainMenuButton.grab_focus()
	$ConfirmMainMenu.popup_centered()

func _on_restart_button_pressed():
	%RestartButton.grab_focus()
	# wait 0.2 second and reload the current scene
	await get_tree().create_timer(0.2).timeout
	_restart()

func _on_confirm_main_menu_confirmed():
	SceneLoader.load_scene(main_menu_scene)
	InGameMenuController.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_confirm_exit_confirmed():
	get_tree().quit()

func _restart():
	SceneLoader.reload_current_scene()
	LevelManager.restart_level()
	InGameMenuController.close_menu()
