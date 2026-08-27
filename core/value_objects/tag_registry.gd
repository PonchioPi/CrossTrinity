@tool
extends Resource
class_name TagRegistry
##An all compatible tag registry. 
##Registers, validates tag sets, and resolves effectivess tags implied by their ids.

@export var tags: Array[TagData] = []:
	set = set_tags

var _by_id: Dictionary = {}

func set_tags(value: Array[TagData]) -> void:
	tags = value
	build_index()

func build_index() -> void:
	_by_id.clear()
	for tag in tags:
		if not has_tag(tag.id):
			_by_id[tag.id] = tag
	validate_tag_set(_by_id.keys())

func has_tag(tag_id: StringName) -> bool:
	return _by_id.has(tag_id)

func get_tag(tag_id: StringName) -> TagData:
	return _by_id.get(tag_id)

func validate_tag_set(tag_ids:Array[StringName]) -> void:
	var errors: Array[String] = []
	for tag_id in tag_ids:
		if not has_tag(tag_id):
			errors.append("Unknown tag: %s" % tag_id)
			continue
		var tag: TagData = get_tag(tag_id)
		for req in tag.requires:
			if req not in tag_ids:
				errors.append("%s requires %s" % [tag_id, req])
		for forb in tag.forbids:
			if forb in tag_ids:
				errors.append("%s forbids %s" % [tag_id, forb])
	for error in errors:
		push_warning(error)

func resolve_effective_tags(tag_ids: Array[StringName]) -> Array[StringName]:
	var out:= tag_ids.duplicate()
	var changed:= true
	while changed:
		changed = false
		for tag_id in out:
			var tag:TagData = get_tag(tag_id)
			if tag == null:
				continue
			for implied in tag.implies:
				if implied not in out:
					out.append(implied)
					changed = true
	return out
