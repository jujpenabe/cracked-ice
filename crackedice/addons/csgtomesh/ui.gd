@tool
extends Button

class_name CSGMeshButton

signal mesh_created(node: MeshInstance3D)

const NODE_NAME_FORMAT = "Mesh%s" # csg name
const NODE_PATH_FORMAT = "%s/" + NODE_NAME_FORMAT # csg parent path

var root : Node
var csg : CSGShape3D
var undo_redo : EditorUndoRedoManager

func show_ui(root: Node, csg: CSGShape3D, undo_redo: EditorUndoRedoManager):
	self.root = root
	self.csg = csg
	self.undo_redo = undo_redo
	show()

func create_mesh(csg: CSGShape3D) -> MeshInstance3D:
	# get the mesh from the CSGShape3D
	var orig_mesh : Mesh = csg.get_meshes()[1]
	var new_mesh : Mesh
	
	# add each surface to new mesh using SurfaceTool, so we can generate an index array
	for i in orig_mesh.get_surface_count():
		var st = SurfaceTool.new()
		st.append_from(orig_mesh, i, Transform3D())
		st.set_material(orig_mesh.surface_get_material(i)) # materials aren't added by append_from for some reason
		st.index() # create the index array
		
		# create new mesh if first surface, otherwise add surface to existing mesh
		if i == 0: new_mesh = st.commit()
		else: st.commit(new_mesh)
	
	# create MeshInstance3D using the mesh we just created
	var mesh_instance = MeshInstance3D.new()
	csg.get_parent().add_child(mesh_instance)
	mesh_instance.owner = root
	mesh_instance.mesh = new_mesh
	mesh_instance.global_transform = csg.global_transform
	mesh_instance.name = NODE_NAME_FORMAT % csg.name
	
	# emit created signal so we can select the new node
	mesh_created.emit(mesh_instance)
	
	return mesh_instance

func remove_mesh(path):
	var node = get_node_or_null(path)
	if node: node.queue_free()

func _on_pressed():
	# add to undo/redo history, which will automatically call create_mesh for us
	undo_redo.create_action("Convert CSG to MeshInstance3D")
	undo_redo.add_do_method(self, "create_mesh", csg)
	undo_redo.add_undo_method(self, "remove_mesh", NODE_PATH_FORMAT % [str(csg.get_parent().get_path()), csg.name]) # kinda hacky?
	undo_redo.commit_action()
