class_name MainMenu
extends Control


@export_file("*.tscn") var game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export var version_name : String = '0.0.0'

var options_scene
var credits_scene
var sub_menu
var play_button_focused_texture : Texture2D
var options_button_focused_texture : Texture2D
var credits_button_focused_texture : Texture2D
var exit_button_focused_texture : Texture2D

func load_scene(scene_path : String):
	SceneLoader.load_scene(scene_path)

func play_game():
	SceneLoader.load_scene(game_scene_path)

func _open_sub_menu(menu : Control):
	sub_menu = menu
	sub_menu.show()
	%BackButton.show()
	%MenuContainer.hide()

func _close_sub_menu():
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	%BackButton.hide()
	%MenuContainer.show()
	%PlayButton.grab_focus()

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

# func _input(event):
# 	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
# 		%PlayButton.grab_focus()

func _setup_for_web():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _setup_version_name():
	AppLog.version_opened(version_name)
	$"%VersionNameLabel".text = "v%s" % version_name

func _setup_play():
	if game_scene_path.is_empty():
		%PlayButton.hide()

func _setup_options():
	if options_packed_scene == null:
		%OptionsButton.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		%OptionsContainer.call_deferred("add_child", options_scene)

func _setup_credits():
	if credits_packed_scene == null:
		%CreditsButton.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		%CreditsContainer.call_deferred("add_child", credits_scene)

func _ready():
	%PlayButton.grab_focus()
	_setup_for_web()
	_setup_version_name()
	_setup_options()
	_setup_credits()
	_setup_play()

func _on_play_button_pressed():
	play_game()

func _on_options_button_pressed():
	_open_sub_menu(options_scene)

func _on_credits_button_pressed():
	_open_sub_menu(credits_scene)
	credits_scene.reset()

func _on_exit_button_pressed():
	get_tree().quit()

func _on_credits_end_reached():
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed():
	_close_sub_menu()

func reset_focused_button_textures():
	# if not null, set the texture
	if play_button_focused_texture != null:
		%PlayButton.set_texture_focused(play_button_focused_texture)
	if options_button_focused_texture != null:
		%OptionsButton.set_texture_focused(options_button_focused_texture)
	if credits_button_focused_texture != null:
		%CreditsButton.set_texture_focused(credits_button_focused_texture)
	if exit_button_focused_texture != null:
		%ExitButton.set_texture_focused(exit_button_focused_texture)

func _on_play_button_button_down():
	play_button_focused_texture = %PlayButton.get_texture_focused()
	%PlayButton.set_texture_focused(null)

func _on_play_button_button_up():
	# Reset all focus textures
	reset_focused_button_textures()

func _on_options_button_button_down():
	options_button_focused_texture = %OptionsButton.get_texture_focused()
	%OptionsButton.set_texture_focused(null)

func _on_options_button_button_up():
	# Reset all focus textures
	reset_focused_button_textures()


func _on_credits_button_button_down():
	credits_button_focused_texture = %CreditsButton.get_texture_focused()
	%CreditsButton.set_texture_focused(null)

func _on_credits_button_button_up():
	# Reset all focus textures
	reset_focused_button_textures()

func _on_exit_button_button_down():
	exit_button_focused_texture = %ExitButton.get_texture_focused()
	%ExitButton.set_texture_focused(null)

func _on_exit_button_button_up():
	# Reset all focus textures
	reset_focused_button_textures()