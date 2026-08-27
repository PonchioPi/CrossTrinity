extends RefCounted
class_name EventData

enum EventType {
	TRANSFORM,
	INFO
}

@export var event_type: EventType = EventType.INFO
@export var event_id: String
@export var source_id: String
@export var target_id: String

@export var payload_id: String
@export var delay: float = .0
@export var priority: int = 0
@export var execute_at: float = .0

var conflict_group: String
var cancel_group: String
var cancelled: bool = false
var resolved_by: String

var sequence: int
var queued_at: float
var payload_f: float
var payload_i: int
var payload_s: String
var payload_tags: PackedStringArray
