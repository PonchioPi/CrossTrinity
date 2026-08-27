extends RefCounted
class_name ConflictBatch

signal batch_opened(batch_id: String)
signal batch_updated(batch_id: String)
signal batch_locked(batch_id: String)
signal batch_resolved(batch_id: String, result: Variant)

enum BatchPhase {
	CREATED = 0,
	OPEN = 1,
	GRACE = 2,
	LOCKED = 3,
	RESOLVED = 4
}

enum ResponseType {
	MISS = 100,
	GOOD = 200,
	SUPER = 300,
	AMAZING = 400,
	EXCELLENT = 500
}

var batch_id: String
var category: String
var channel: String
var source_id: String
var target_ids: PackedStringArray

var source_event: EventData

var phase: BatchPhase = BatchPhase.CREATED
var created_at: float = .0
var open_until: float = .0
var grace_until: float = .0
var locked_at: float = .0

var inputs: Array[Dictionary]
var result: Variant
var sequence_counter: int = 0

var resolver: Callable
var thresholds: Dictionary[ResponseType, PackedFloat32Array]

func setup(
	p_batch_id: String,
	p_category: String,
	p_channel: String,
	p_source_id: String,
	p_target_ids: PackedStringArray,
	p_source_event: EventData,
	p_now: float,
	p_open_duration: float,
	p_grace_duration: float,
	p_resolver: Callable,
	p_thresholds: Dictionary[ResponseType, PackedFloat32Array] = {}
	) -> void:
	batch_id = p_batch_id
	category = p_category
	channel = p_channel
	source_id = p_source_id
	target_ids = p_target_ids
	source_event = p_source_event
	created_at = p_now
	open_until = p_now + maxf(p_open_duration, 0.0)
	grace_until = open_until + maxf(p_grace_duration, 0.0)
	resolver = p_resolver
	thresholds = p_thresholds
	phase = BatchPhase.OPEN
	batch_opened.emit(batch_id)
	#EventBus.conflict_batch_created.emit(batch_id)

func add_input(payload: Dictionary, now: float) -> bool:
	if not is_active():
		return false
	if payload.is_empty():
		return false
	var accepted := false
	if now <= open_until:
		accepted = true
	elif now <= grace_until:
		payload["late"] = true
		accepted = true
	if not accepted:
		return false

	payload["response_type"] = evaluate_input(payload, now)
	payload["sequence"] = sequence_counter
	sequence_counter += 1
	inputs.append(payload)
	return true

func evaluate_input(_payload:Dictionary, now:float) -> ResponseType:
	var delta: float = abs(now - open_until)
	for score in thresholds.keys():
		match thresholds[score].size():
			1:
				if delta > thresholds[score][0]:
					continue
				return score
			2:
				if delta < thresholds[score][0] or delta > thresholds[score][1]:
					continue
				return score
			_:
				continue
	return ResponseType.MISS

func update(now: float) -> void:
	if phase == BatchPhase.RESOLVED:
		return
	if phase == BatchPhase.OPEN and now > open_until:
		phase = BatchPhase.GRACE
	if phase == BatchPhase.GRACE and now > grace_until:
		lock_and_resolve(now)
	batch_updated.emit(batch_id)

func lock_and_resolve(now: float) -> Variant:
	if phase == BatchPhase.RESOLVED:
		return result
	phase = BatchPhase.LOCKED
	locked_at = now
	batch_locked.emit(batch_id)
	if resolver.is_valid():
		result = resolver.call(self)
	else:
		result = {
			"type": "error",
			"batch_id": batch_id,
			"status": "missing_resolver"
		}
	phase = BatchPhase.RESOLVED
	batch_resolved.emit(batch_id, result)
	return result

func is_active() -> bool:
	return phase == BatchPhase.OPEN or phase == BatchPhase.GRACE

func is_locked() -> bool:
	return phase == BatchPhase.LOCKED or phase == BatchPhase.RESOLVED

func has_inputs() -> bool:
	return not inputs.is_empty()

func get_input_count() -> int:
	return inputs.size()

func get_inputs_for_target(target_id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for payload in inputs:
		if payload.get("target_id", "") == target_id:
			out.append(payload)
	return out
