extends RefCounted
class_name EffectApplier

signal effect_applied(effect_type: String, payload: Dictionary)

func apply_rules(
	context: ReactionContext,
	rules: Array[RuleData]
	) -> Array[EventData]:
	var events: Array[EventData] = []
	for rule in rules:
		if rule == null:
			continue
		for i in range(rule.effect_types.size()):
			var event := _apply_compact_effect(context, rule, i)
			if event != null:
				events.append(event)
				#effect_applied.emit(String(event.get("event_type")), event)
	return events

static func _apply_compact_effect(
	context: ReactionContext,
	rule: RuleData,
	index: int) -> EventData:
	var effect_type := int(rule.effect_types[index])
	var key := ""
	var value: Variant = null
	
	if index < rule.effect_keys.size():
		key = rule.effect_keys[index]
	if index < rule.effect_values.size():
		value = rule.effect_values[index]

	match effect_type:
		RuleData.EffectType.TRANSFORM:
			return _make_transform_event(context, rule, key, value)
		_:
			return null

static func _make_transform_event(
	context: ReactionContext,
	rule: RuleData,
	key: String,
	value: Variant) -> EventData:
	var ev := EventData.new()
	ev.event_type = EventData.EventType.TRANSFORM
	ev.event_id = rule.id
	ev.source_id = context.source_id
	ev.target_id = context.target_id
	ev.payload_s = key
	ev.payload_i = int(value) if value is int else 0
	ev.priority = rule.priority
	ev.delay = _get_delay(rule)
	return ev

static func _get_delay(rule: RuleData) -> float:
	if rule.metadata.has("delay"):
		return float(rule.metadata["delay"])
	return 0.0
