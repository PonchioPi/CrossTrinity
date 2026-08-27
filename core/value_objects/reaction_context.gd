extends RefCounted
class_name ReactionContext

@export var source_id: String = ""
@export var target_id: String = ""
@export var environment_id: String = ""

@export var tags: PackedStringArray
@export var source_tags: PackedStringArray
@export var target_tags: PackedStringArray
@export var environment_tags: PackedStringArray

@export var action_id: String
@export var rule_group: String
@export var seed : int = 0

@export var flags: Dictionary[String, bool]
@export var f_values: Dictionary[String, float]
@export var i_values: Dictionary[String, int]
@export var meta: Dictionary[String, Variant]

#region Getters
func get_f_value(key:String, default_value:float = 0.0) -> float:
	return float(f_values.get(key, default_value))

func get_i_value(key:String, default_value:int = 0) -> int:
	return int(i_values.get(key, default_value))

func get_flag(key:String, default_value:bool = false) -> bool:
	return bool(flags.get(key, default_value))

func get_any_value(key:String) -> Variant:
	if meta.has(key):
		return meta[key]
	if f_values.has(key):
		return f_values[key]
	if i_values.has(key):
		return i_values[key]
	if flags.has(key):
		return flags[key]
	return null

#endregion

#region Methods
func has_tag(tag: String) -> bool:
	return tags.has(tag) or source_tags.has(tag) or target_tags.has(tag) or environment_tags.has(tag)

func has_all_tags(required: PackedStringArray) -> bool:
	for tag in required:
		if not has_tag(tag):
			return false
	return true

func has_any_tag(required: PackedStringArray) -> bool:
	for tag in required:
		if has_tag(tag):
			return true
	return false

func has_id(id: String) -> bool:
	return flags.has(id) or f_values.has(id) or i_values.has(id)\
	 or meta.has(id) or environment_id == id or source_id == id\
	 or target_id == id or action_id == id 

func has_all_ids(required: PackedStringArray) -> bool:
	for id in required:
		if not has_id(id):
			return false
	return true

func has_any_id(required: PackedStringArray) -> bool:
	for id in required:
		if has_id(id):
			return true
	return false

func merge_tags(extra_tags: PackedStringArray) -> void:
	for tag in extra_tags:
		if not tags.has(tag):
			tags.append(tag)

func clear_runtime_state() -> void:
	flags.clear()
	f_values.clear()
	i_values.clear()
	meta.clear()

func duplicate_context() -> ReactionContext:
	var copy := ReactionContext.new()
	copy.source_id = source_id
	copy.target_id = target_id
	copy.environment_id = environment_id
	
	copy.tags = tags.duplicate()
	copy.source_tags = source_tags.duplicate()
	copy.target_tags = target_tags.duplicate()
	copy.environment_tags = environment_tags.duplicate()
	
	copy.action_id = action_id
	copy.rule_group = rule_group
	copy.seed = seed
	
	copy.flags = flags.duplicate()
	copy.f_values = f_values.duplicate()
	copy.i_values = i_values.duplicate()
	copy.meta = meta.duplicate(true)
	return copy
#endregion
