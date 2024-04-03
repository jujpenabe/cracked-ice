extends Node3D

var title_menu: PackedScene = preload("res://CrackedIce/Menus/Title/title.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start intro animation

	# wait 2 secs and instantiate the main menu
	await get_tree().create_timer(1.0).timeout
	var main_menu_instance = title_menu.instantiate()
	add_child(main_menu_instance)
