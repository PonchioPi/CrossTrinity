extends RefCounted
class_name SystemResolver

enum SelectionMode {
	BEST_ONLY = 0,
	ALL_COMPATIBLE = 1,
	BEST_BY_GROUP = 2
}

static func _rule_resolve(
	context: ReactionContext,
	rules: Array[RuleData],
	selection_mode: SelectionMode = SelectionMode.BEST_ONLY
	) -> Array[RuleData]:
	var candidates: Array[RuleData] = []
	
	for rule in rules:
		if rule == null:
			continue
		if rule.matches(context):
			candidates.append(rule)
	
	if candidates.is_empty():
		return []
	
	candidates.sort_custom(func(a: RuleData, b: RuleData) -> bool: return _compare_rules(a,b))
	
	match selection_mode:
		SelectionMode.ALL_COMPATIBLE:
			return candidates
		SelectionMode.BEST_BY_GROUP:
			return _select_best_rule_per_group(candidates)
		_:
			return _select_best_rule_only(candidates)

static func _compare_rules(a: RuleData, b: RuleData) -> bool:
	if a.priority != b.priority:
		return a.priority > b.priority
	var sa := a.get_specificity_score()
	var sb := b.get_specificity_score()
	if sa != sb:
		return sa > sb
	if a.weight != b.weight:
		return a.weight > b.weight
	return a.id > b.id

static func _select_best_rule_only(rules: Array[RuleData]) -> Array[RuleData]:
	if rules.is_empty():
		return []
	return [rules[0]]

static func _select_best_rule_per_group(rules: Array[RuleData]) -> Array[RuleData]:
	var best_by_group: Dictionary[String, RuleData] = {}
	for rule in rules:
		var group := rule.conflict_group
		if group.is_empty():
			group = "default"
		if not best_by_group.has(group):
			best_by_group[group] = rule
			continue
		var current := best_by_group[group]
		if _compare_rules(rule, current):
			best_by_group[group] = rule
	
	var selected: Array[RuleData] = []
	for group in best_by_group.keys():
		selected.append(best_by_group[group])
	
	selected.sort_custom(func(a: RuleData, b: RuleData) -> bool: return _compare_rules(a,b))
	return selected
