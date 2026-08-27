extends RefCounted
## A consumer for Timeline events, be sure to create as many _apply_event_type functions as there is  event types in [enum EventData.EventType].
class_name EventConsumer

static func handle_event(event: EventData) -> void:
	pass

static func handles_event_type(event_type: int) -> bool:
	return false
