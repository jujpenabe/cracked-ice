class_name MainMenu
extends Control


@export_file("*.tscn") var game_scene_path : String
@export_file("*.tscn") var test_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene
@export var version_name : String = '0.0.0'

@export var audio_bus : StringName = &"SFX"

@export var intro : AudioStream
@export var engine_start : AudioStream


# export group sfx
@export_group("UI SFX")
@export var button_focused : AudioStream
@export var button_pressed : AudioStream
@export var options : AudioStream
@export var credits : AudioStream
@export var exit : AudioStream

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
	var load_path = "user://saved_game.scn"
	if FileAccess.file_exists(load_path):
		SceneLoader.load_scene(load_path)
		print("Game loaded from: " + load_path)
	else:
		print("No game saved at: " + load_path + " - Starting new game.")
		SceneLoader.load_scene(game_scene_path)


func play_test():
	SceneLoader.load_scene(test_scene_path)

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
		#%ExitButton.hide()
		pass

func _setup_version_name():
	AppLog.version_opened(version_name)
	%VersionNameLabel.text = version_name

func _setup_play():
	if game_scene_path.is_empty():
		%PlayButton.hide()

func _setup_main_theme():
	if intro != null:
		ProjectMusicController.play_stream(intro)
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
	_setup_for_web()
	_setup_options()
	_setup_version_name()
	_setup_credits()
	_setup_play()
	_setup_main_theme()
	# wait 0.44 second and focus
	await get_tree().create_timer(0.44).timeout
	%PlayButton.grab_focus()

func _on_play_button_pressed():
	ProjectMusicController.fade_out(4.4)
	ProjectUISoundController.play_ui_sound(engine_start)
	play_game()

func _on_level_test_button_pressed():
	play_test()

func _on_options_button_pressed():
	# play sfx
	ProjectUISoundController.play_ui_sound(options)
	_open_sub_menu(options_scene)

func _on_credits_button_pressed():
	ProjectUISoundController.play_ui_sound(credits)
	_open_sub_menu(credits_scene)
	credits_scene.reset()

func _on_exit_button_pressed():
	ProjectUISoundController.play_ui_sound(exit)
	# wait 0.2 second and quit
	await get_tree().create_timer(0.5).timeout
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
	if (OS.has_feature("web")):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		%ForegroundThanksForPlaying.show()

func _on_exit_button_button_up():
	# Reset all focus textures
	reset_focused_button_textures()


func _on_version_name_label_meta_clicked(meta:String) -> void:
	if meta.begins_with("https://"):
		var _err = OS.shell_open(meta)

func _on_button_focus_entered() -> void:
	# play the hover sfx
	ProjectUISoundController.play_ui_sound(button_focused)
