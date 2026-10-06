@tool
extends Node

enum ProfileSelectionMode {
    FIRST,
    PRIORITY,
    SPECIFICITY,
    CUSTOM,
    DEFAULT
}

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	load_rules()

var conflict_profiles: Dictionary[String, Array] #key: "category:channel"
var rules_by_tag : Dictionary[String, Array]
var rules_by_id: Dictionary[String, Array]
var tags_by_id: Dictionary[StringName, TagData]
#Relations de tags 
var tag_implies: Dictionary[StringName, PackedStringArray] # tag -> tags à ajouter
var tag_forbids: Dictionary[StringName, PackedStringArray] # tag -> tags à supprimer

func load_conflict_profiles() -> void:
	for profile_path in ResourceLoader.list_directory("res://data/conflicts/conflict_profiles/"):
		var profile := load("res://data/conflicts/conflict_profiles/"+profile_path) as ConflictProfile
		if Engine.is_editor_hint():
			if not profile:
				printerr("This file doesn't belong to the conflict profiles file: %s"
				%[profile_path])
				continue
			print("New conflict profile added: "+profile_path)
		var key := "%s:%s" % [
			str(profile.category) if profile.category else "*",
			str(profile.channel) if profile.category and profile.channel else "*"]
		if not conflict_profiles.has(key):
			var new_arr: Array[ConflictProfile] = []
			conflict_profiles[key] = new_arr
		conflict_profiles[key].append(profile)
		if Engine.is_editor_hint():
			print("[GameDatabase] Loaded conflict profile: %s (key: %s, priority: %s)" %
			[profile.resource_name, key, profile.priority])

func load_rules() -> void:
	rules_by_tag["default"] = []
	rules_by_id["default"] = []
	for rule_path in ResourceLoader.list_directory("res://data/rules/rules/"):
		var rule := load("res://data/rules/rules/"+rule_path) as RuleData
		if Engine.is_editor_hint():
			if not (rule is RuleData):
				printerr("This file doesn't belong to the rules file: %s" % [rule_path])
				continue
			print("New rule added: "+rule_path)
		if rule.has_no_required_tag():
			rules_by_tag["default"].append(rule)
		if rule.has_no_required_id():
			rules_by_id["default"].append(rule)
		if rule.has_no_required_tag() and rule.has_no_required_id():
			continue
		var tags : PackedStringArray = rule.get_required_tags()
		var ids : PackedStringArray = rule.get_required_ids()
		if tags:
			for tag in tags:
				rules_by_tag[tag] = rules_by_tag.get(tag, [])
				rules_by_tag[tag].append(rule)
		if ids:
			for id in ids:
				rules_by_id[id] = rules_by_id.get(id, [])
				rules_by_id[id].append(rule)
	if Engine.is_editor_hint():
		print(rules_by_id, "\n", rules_by_tag)

func load_tags() -> void:
	for tag_path in ResourceLoader.list_directory("res://data/tags/tags/"):
		var tag := load("res://data/tags/tags/"+tag_path) as TagData
		if Engine.is_editor_hint():
			if not tag:
				printerr("This file doesn't belong to the tags file: %s" % [tag_path])
				continue
			if tags_by_id.has(tag.id):
				printerr("Duplicate tag ID : %s"%[tag.id])
				continue
			print("New tag added: "+tag_path)
		if not tag.category.is_empty() and tag.category not in tag.implies:
			tag.implies.append(tag.category)
			
		tags_by_id[tag.id] = tag
		tag_implies[tag.id] = tag.implies
		tag_forbids[tag.id] = tag.forbids
	validate_tag_relations()
	if Engine.is_editor_hint():
		print(tags_by_id)

func validate_tag_relations() -> void:
	for tag_id in tags_by_id.keys():
		var tag := tags_by_id[tag_id]
		
		for required_id in tag.requires:
			if not tags_by_id.has(required_id):
				printerr("[GameDatabase] Tag '%s' requires unknown tag '%s'"
				%[tag_id, required_id])
			if required_id in tag.forbids:
				printerr("[GameDatabase] Tag '%s' both requires and forbids '%s'"
				%[tag_id, required_id])
		for forbidden_id in tag.forbids:
			if not tags_by_id.has(forbidden_id):
				printerr("[GameDatabase] Tag '%s' forbids unknown tag '%s'"
				%[tag_id, forbidden_id])
		for implied_id in tag.implies:
			if not tags_by_id.has(implied_id):
				printerr("[GameDatabase] Tag '%s' implies unknown tag '%s'"
				%[tag_id, implied_id])
			if implied_id in tag.forbids:
				printerr("[GameDatabase] Tag '%s' both implies and forbids '%s'"
				%[tag_id, implied_id])


func get_rules(tags:PackedStringArray, ids:PackedStringArray) -> Array[RuleData]:
	var rules_package:Array[RuleData]
	var seen:Dictionary[String, bool]
	
	if rules_by_tag.has("default"):
		for rule in rules_by_tag["default"]:
			if not seen.has(rule.resource_path):
				rules_package.append(rule)
				seen[rule.resource_path] = true
	if rules_by_id.has("default"):
		for rule in rules_by_id["default"]:
			if not seen.has(rule.resource_path):
				rules_package.append(rule)
				seen[rule.resource_path] = true

	for tag in tags:
		if not rules_by_tag.has(tag):
			continue
		for rule in rules_by_tag[tag]:
			if not seen.has(rule.resource_path):
				rules_package.append(rule)
				seen[rule.resource_path] = true
	for id in ids:
		if not rules_by_id.has(id):
			continue
		for rule in rules_by_id[id]:
			if not seen.has(rule.resource_path):
				rules_package.append(rule)
				seen[rule.resource_path] = true
	return rules_package

func get_conflict_profile(category:String, channel:String,
selection_mode: ProfileSelectionMode) -> ConflictProfile:
	var exact_key:= "%s:%s" % [category, channel]
	if conflict_profiles.has(exact_key):
		return _select_from_profiles(
			conflict_profiles[exact_key], category, channel,
			selection_mode
			)
	
	var wildcard_key:= "%s:*" % category
	if conflict_profiles.has(wildcard_key):
		return _select_from_profiles(
			conflict_profiles[wildcard_key], category, channel,
			selection_mode
		)
	
	if conflict_profiles.has("*:*"):
		return _select_from_profiles(
			conflict_profiles["*:*"], category, channel,
			selection_mode
		)
	
	return _get_default_profile()

func _get_default_profile() -> ConflictProfile:
	var default := ConflictProfile.new()
	default.open_duration = 0.5
	default.grace_duration = 0.1
	default.thresholds = {
		ConflictBatch.ResponseType.EXCELLENT: PackedFloat32Array([0.05]),
		ConflictBatch.ResponseType.SUPER: PackedFloat32Array([0.10]),
		ConflictBatch.ResponseType.GOOD: PackedFloat32Array([0.20]),
		ConflictBatch.ResponseType.MISS: PackedFloat32Array([0.50])
	}
	return default

func _select_from_profiles(profiles: Array[ConflictProfile], category: String,
 channel: String, selection_mode: ProfileSelectionMode = ProfileSelectionMode.DEFAULT) -> ConflictProfile:
	if profiles.is_empty():
		return _get_default_profile()
	match selection_mode:
		ProfileSelectionMode.FIRST:
			return profiles[0]
		ProfileSelectionMode.PRIORITY:
			return _select_by_priority(profiles)
		ProfileSelectionMode.SPECIFICITY:
			return _select_by_specificity(profiles, category, channel)
		ProfileSelectionMode.CUSTOM:
			return _select_by_custom(profiles, category, channel)
		_:
			return profiles[0]

func _select_by_priority(profiles: Array[ConflictProfile]) -> ConflictProfile:
	var best: ConflictProfile = profiles[0]
	for profile in profiles:
		if profile.priority > best.priority:
			best = profile
	return best

func _select_by_specificity(profiles: Array[ConflictProfile],
 category: String, channel: String) -> ConflictProfile:
	var best:= profiles[0]
	var best_score := _calculate_specificity_score(profiles[0], category, channel)
	
	for profile in profiles:
		var score := _calculate_specificity_score(profile, category, channel)
		if score > best_score:
			best = profile
			best_score = score
	return best

func _calculate_specificity_score(profile: ConflictProfile,
category: String, channel: String) -> int:
	var score := 0
	if profile.category == category and profile.channel == channel:
		score += 100
	elif profile.cateogry == category:
		score += 75 if profile.channel else 50
	elif not profile.category:
		score += 25 if profile.channel else 10
	if profile.channel == channel:
		score += 25
	return score

func _select_by_custom(profiles: Array[ConflictProfile], 
category: String, channel: String) -> ConflictProfile:
	#Hook for custom logic (i.e: callback, signal, etc.)
	#By default, returns the first element
	return profiles[0]

func expand_tags(tags: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = tags.duplicate() 
	var to_remove: PackedStringArray = []
	
	for tag in tags:
		
		if not tags_by_id.has(tag):
			continue
		
		if tag_implies.has(tag):
			for implied in tag_implies[tag]:
				if implied not in result:
					result.append(implied)

		if tag_forbids.has(tag):
			for forbidden in tag_forbids[tag]:
				if forbidden not in to_remove:
					to_remove.append(forbidden)
	
	for forbidden in to_remove:
		if forbidden in result:
			result.remove_at(result.find(forbidden))
	if "default" not in result:
		result.append("default")
	return result
