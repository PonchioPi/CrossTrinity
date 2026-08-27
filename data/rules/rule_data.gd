extends Resource
class_name RuleData

enum ConditionType {
	HAS_TAG,
	HAS_ALL_TAGS,
	HAS_ANY_TAG,
	HAS_ID,
	HAS_ALL_IDS,
	HAS_ANY_ID,
	F_MIN_VALUE,
	F_MAX_VALUE,
	I_MIN_VALUE,
	I_MAX_VALUE,
	FLAG,
	F_EQUALS,
	I_EQUALS,
	EQUALS,
	ALLOWED
}

enum EffectType {
	MODIFY_VALUE,
	TRANSFORM
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export var priority: int = 0
@export var specificity: int = -1
@export var weight: int = 0

@export var conflict_group: String
@export var exclusive: bool = false
@export var enabled: bool = true

@export var required_tags: PackedStringArray
@export var forbidden_tags: PackedStringArray
@export var any_tags: PackedStringArray

@export var required_source_tags: PackedStringArray
@export var required_target_tags: PackedStringArray
@export var required_environment_tags: PackedStringArray

@export var required_ids: PackedStringArray
@export var forbidden_ids: PackedStringArray
@export var any_ids: PackedStringArray

@export var required_source_ids: PackedStringArray
@export var required_target_ids: PackedStringArray
@export var required_environment_ids: PackedStringArray

@export var condition_types: Array[ConditionType]
@export var condition_keys: PackedStringArray

## Similar to an all-in-one:[codeblock lang=gdscript]
##@export var f_min_values: Array[float]
##@export var f_max_values: Array[float]
##@export var i_min_values: Array[int]
##@export var i_max_values: Array[int]
##@export var i_equals_values: Array[int]
##@export var f_equals_values: Array[float]
##@export var equals_values: Array[Variant]
##@export var allowed: Array[Variant]
## [/codeblock] [br]
## All condition values goes here following the [member RuleData.condition_types]' order.
## It can also contain ids or tags if needed.
@export var condition_values: Array[Variant]

@export var effect_types: PackedInt32Array
@export var effect_keys: PackedStringArray
@export var effect_values: Array[Variant]

@export var tags_added: PackedStringArray
@export var tags_removed: PackedStringArray

@export var metadata: Dictionary[String, Variant]

func get_specificity_score() -> int:
	if specificity >= 0:
		return specificity
	var score := 0
	score += required_tags.size() * 10
	score += forbidden_tags.size() * 3
	score += any_tags.size() * 4
	score += required_source_tags.size() * 6
	score += required_target_tags.size() * 6
	score += required_environment_tags.size() * 2

	score += required_ids.size() * 10
	score += forbidden_ids.size() * 3
	score += any_ids.size() * 4
	score += required_source_ids.size() * 6
	score += required_target_ids.size() * 6
	score += required_environment_ids.size() * 2

	score += condition_types.size() * 5
	score += effect_types.size()
	return score

func matches(context: ReactionContext) -> bool:
	if not enabled:
		return false
	if not context.has_all_tags(required_tags):
		return false
	if not forbidden_tags.is_empty() and context.has_any_tag(forbidden_tags):
		return false
	if not any_tags.is_empty() and not context.has_any_tag(any_tags):
		return false
	if not context.has_all_ids(required_ids):
		return false
	if not forbidden_ids.is_empty() and context.has_any_id(forbidden_ids):
		return false
	if not any_ids.is_empty() and not context.has_any_id(any_ids):
		return false
	if not _match_compact_conditions(context):
		return false
	return true

func _match_compact_conditions(context: ReactionContext) -> bool:
	var count := mini(condition_types.size(), mini(condition_keys.size(), condition_values.size()))
	for i in count:
		if not _check_compact_condition(
			int(condition_types[i]),str(condition_keys[i]), condition_values[i],
			 context):
			return false
	return true

func _check_compact_condition(t:int, key:String, value:Variant, context: ReactionContext) -> bool:
	match t:
		ConditionType.HAS_TAG:
			return context.has_tag(key)
		ConditionType.HAS_ALL_TAGS:
			return context.has_all_tags(value as PackedStringArray)
		ConditionType.HAS_ANY_TAG:
			return context.has_any_tag(value as PackedStringArray)
		ConditionType.HAS_ID:
			return context.has_id(key)
		ConditionType.HAS_ALL_IDS:
			return context.has_all_ids(value as PackedStringArray)
		ConditionType.HAS_ANY_ID:
			return context.has_any_id(value as PackedStringArray)
		ConditionType.F_MIN_VALUE:
			return context.get_f_value(key, 0.0) >= float(value)
		ConditionType.F_MAX_VALUE:
			return context.get_f_value(key, 0.0) <= float(value)
		ConditionType.I_MIN_VALUE:
			return context.get_i_value(key, 0) >= int(value)
		ConditionType.I_MAX_VALUE:
			return context.get_i_value(key, 0) <= int(value)
		ConditionType.FLAG:
			return context.get_flag(key, false) == bool(value)
		ConditionType.I_EQUALS:
			return context.get_i_value(key, 0) == int(value)
		ConditionType.F_EQUALS:
			return context.get_f_value(key, 0.0) == float(value)
		ConditionType.EQUALS:
			return context.get_any_value(key) == value
		ConditionType.ALLOWED:
			return context.get_any_value(key) in (value as Array)
		_:
			return true
