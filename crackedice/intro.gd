extends Node3D

var main_menu: PackedScene = preload("res://ci_main_menu.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start intro animation
	
	# wait 2 secs and instantiate the main menu
	await get_tree().create_timer(2.0).timeout
	var main_menu_instance = main_menu.instantiate()
	add_child(main_menu_instance)
