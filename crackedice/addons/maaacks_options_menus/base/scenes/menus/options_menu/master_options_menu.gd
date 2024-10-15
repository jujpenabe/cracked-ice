class_name MasterOptionsMenu
extends Control

var guard_timer : Timer

func _ready():
	guard_timer = Timer.new()
	guard_timer.wait_time = 0.1
	guard_timer.one_shot = true
	add_child(guard_timer)

func _unhandled_input(event):
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_page_down") || Input.is_joy_button_pressed(0, JOY_BUTTON_RIGHT_SHOULDER) && guard_timer.is_stopped():
		$TabContainer.current_tab = ($TabContainer.current_tab+1) % $TabContainer.get_tab_count()
		guard_timer.start()
	elif event.is_action_pressed("ui_page_up") || Input.is_joy_button_pressed(0, JOY_BUTTON_LEFT_SHOULDER) && guard_timer.is_stopped():
		if $TabContainer.current_tab == 0:
			$TabContainer.current_tab = $TabContainer.get_tab_count()-1
		else:
			$TabContainer.current_tab = $TabContainer.current_tab-1
		guard_timer.start()

func _on_visibility_changed() -> void:
	if visible:
		%TabContainer.get_tab_bar().grab_focus()
	
