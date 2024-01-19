class_name Util

static func get_encompassing_groups(node: Node) -> PackedStringArray:
	if !node:
		return PackedStringArray()
	var groups := PackedStringArray()
	groups.append_array(node.get_groups())
	for i: String in get_encompassing_groups(node.get_parent()):
		if !groups.has(i):
			groups.append(i)
	return groups

static func get_encommpassing_groups_as_keys(node: Node) -> Dictionary:
	var data := {}
	for group: String in node.get_groups():
		data[group] = node
	var parent_data := get_encommpassing_groups_as_keys(node.get_parent())
	for key : String in parent_data:
		if !data.has(key):
			data[key] = parent_data[key]
	return data
