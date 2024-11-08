extends Node3D

var player_inside := false
var player_visible := false

func _ready() -> void:
	pass


func _on_area_3d_body_entered(body:Node3D) -> void:
	player_inside = true
	visible = true
	print("body entered: ", body.name)


func _on_area_3d_body_exited(body:Node3D) -> void:
	print("body exited: ", body.name)
	player_inside = false
	if !player_visible:
		print("Player not visible")
		visible = false 

func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	player_visible = true
	visible = true

func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	player_visible = false
	if !player_inside:
		print("hided")
		visible = false
