@tool
extends Node

func _enter_tree() -> void:
	EventBus.conflict_batch_resolved.connect(process_conflict_resolutions)
	EventBus.input_received.connect(_on_input_received)

func process_conflict_resolutions(info:Variant) -> void:
	match typeof(info):
		TYPE_DICTIONARY:
			var context:=_build_context_from_input(info)
			_dispatch_context(context)
		TYPE_ARRAY:
			var contexts:= _build_contexts_from_resolution(info as Array[Dictionary])
			for context in contexts:
				_dispatch_context(context)
		_:
			push_warning("[InteractionEngine] Unexpected info type: ", typeof(info))
			return

func _build_context_from_input(input:Dictionary) -> ReactionContext:
	var context := ReactionContext.new()
	
	var raw_tags: PackedStringArray = input.get("tags", [])
	raw_tags.append_array(input.get("source_tags", []))
	raw_tags.append_array(input.get("target_tags", []))
	raw_tags.append_array(input.get("environment_tags", []))
	
	var normalized_tags := GameDatabase.expand_tags(raw_tags)
	
	context.source_id = input.get("source_id", "")
	context.target_id = input.get("target_id", "")
	context.action_id = input.get("action_id", "")
	context.tags = normalized_tags
	context.set_source_tags(input.get("source_tags", []))
	context.set_target_tags(input.get("target_tags", []))
	context.set_environment_tags(input.get("environment_tags", []))
	context.set_source_ids(input.get("source_ids", []))
	context.set_target_ids(input.get("target_ids", []))
	context.set_environment_ids(input.get("environment_ids", []))
	if input.has("outcome"):
		context.meta["outcome"] = input["outcome"]
	return context

func _build_contexts_from_resolution(resolution:Array[Dictionary]) -> Array[ReactionContext]:
	var result:Array[ReactionContext] = []
	var context:ReactionContext
	for input in resolution:
		context = _build_context_from_input(input)
		result.append(context)
	return result

func _dispatch_context(context:ReactionContext) -> void:
	var rules:Array[RuleData] = RuleResolver._rule_resolve(context, GameDatabase.get_rules(context.tags, context.ids))
	var events:Array[EventData] = EffectApplier.apply_rules(context, rules)

	for event in events:
		Timeline.schedule_event(event)

func _on_input_received(input:Dictionary) -> void:
	var context:= _build_context_from_input(input)
	_dispatch_context(context)
