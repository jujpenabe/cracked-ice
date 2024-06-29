@tool
extends EditorPlugin

var ui : CSGMeshButton

func selection_changed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	
	if selection.size() == 1 and selection[0] is CSGShape3D and selection[0].is_root_shape():
		ui.show_ui(get_tree().get_edited_scene_root(), selection[0], get_undo_redo())
	else:
		ui.hide()
		
func mesh_node_created(node: MeshInstance3D):
	var selection = get_editor_interface().get_selection()
	
	selection.clear()
	selection.add_node(node)

func _enter_tree():
	ui = preload("res://addons/csgtomesh/ui.tscn").instantiate()
	ui.mesh_created.connect(self.mesh_node_created)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, ui)
	ui.hide()
	
	get_editor_interface().get_selection().selection_changed.connect(self.selection_changed)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, ui)
	if ui: ui.free()
