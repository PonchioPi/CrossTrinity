extends Node

signal timeline_event_scheduled(event_data: EventData)
signal timeline_event_dispatched(system_name: String, event_data: EventData)
signal event_published(system_name: String, payload: Dictionary)
signal timeline_emptied

signal conflict_batch_resolved(
	batch_id: String, category: String,
	channel: String, result: Variant)

signal conflict_resolver_missing(
	category: String, channel: String, 
	batch_id: String)

signal input_received(input: Dictionary)
signal inputs_received(inputs: Array[Dictionary])
