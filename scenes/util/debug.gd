class_name Debug
## Static class used as a helper library for debug purposes.
##
## These functions are not optimized for performance, 
## but for readability in case of future modification.
##

# TODO: When method overloading is added, consolidate the following.
# Or keep it the same for more type safety?
static func obj_info(obj: Object) -> String:
	return obj.get_class() + "(%s)" % obj.get_script().get_path() if obj.get_script() != null else obj.get_class()
static func node_info(node: Node) -> String:
	return obj_info(node)
static func res_info(res: Resource) -> String:
	return obj_info(res)

static func abstr_func(obj: Object) -> void:
	if OS.has_feature("release"):
		return
	var stack := get_stack()
	var last_call : Dictionary = stack[1]
	var func_name := last_call["function"] as String
	push_error("{0} does not implement method {1}".format([obj_info(obj), func_name]))

const TREE_INDENT = "\t"
static func _tree_info(node: Node) -> String:
	return (node.name + ": %s" % node_info(node))
static func _dump_tree_helper(x: Node, level : int) -> String:
	var info := TREE_INDENT.repeat(level) + _tree_info(x)
	var sublevels_trees := PackedStringArray()
	for sub : Node in x.get_children():
		sublevels_trees.append(_dump_tree_helper(sub, level + 1))
	var sublevels := "".join(sublevels_trees)
	return info + "\n" + sublevels
static func dump_tree(node: Node) -> void:
	print(_dump_tree_helper(node, 0))
