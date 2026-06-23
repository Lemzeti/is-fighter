class_name Util


## Recursive getter for all children of a node
## and all of their children's children. Is children a real word?
static func get_descendants(node : Node) -> Array[Node]:
	var descendants : Array[Node] = []
	for child in node.get_children():
		descendants.append(child) # Add child
		if child.get_child_count() > 0:
			descendants.append_array(get_descendants(child)) # Add grandchildren
	return descendants
