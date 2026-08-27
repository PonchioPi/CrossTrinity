extends Node

signal batch_created(batch_id: String)
signal batch_removed(batch_id: String)
signal batch_resolved(batch_id: String, result: Variant)
signal resolver_missing(category: String, channel: String, batch_id: String)

@export var open_duration_default: float = 0.10
@export var grace_duration_default: float = 0.03
@export var auto_process: bool = true

var current_time: float = .0
var active_batches: Dictionary[String, ConflictBatch]
var resolver_registry: Dictionary[String, Callable]
var _timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_process:
		_timer = Timer.new()
		_timer.one_shot = false
		_timer.wait_time = 0.01
		_timer.autostart = true
		add_child(_timer)
		_timer.timeout.connect(_on_tick)

func _process(delta: float) -> void:
	if not auto_process:
		process(current_time + delta)

func register_resolver(
	category: String, channel: String,
	resolver: Callable) -> void:
	resolver_registry[_make_registry_key(category, channel)] = resolver

func unregister_resolver(
	category: String, channel: String) -> void:
	resolver_registry.erase(_make_registry_key(category, channel))

func has_resolver(category: String, channel: String) -> bool:
	return resolver_registry.has(_make_registry_key(category, channel))

func _get_resolver(category: String, channel: String) -> Callable:
	var key := _make_registry_key(category, channel)
	if resolver_registry.has(key):
		return resolver_registry[key]
	var category_key := _make_registry_key(category, "*")
	if resolver_registry.has(category_key):
		return resolver_registry[category_key]
	if resolver_registry.has("*:*"):
		return resolver_registry["*:*"]
	return Callable()

func create_batch(
	category: String,
	channel: String,
	source_id: String,
	target_ids: PackedStringArray,
	source_event: EventData,
	now : float = -1.0,
	profile: ConflictProfile = null
	) -> ConflictBatch:
	var t := current_time if now < 0.0 else now
	var real_open := open_duration_default if profile == null else profile.open_duration
	var real_grace := grace_duration_default if profile == null else profile.grace_duration
	var resolver := _get_resolver(category, channel)
	var batch := ConflictBatch.new()
	var batch_id := _make_batch_id(category, channel, source_id, t)
	var thresholds := profile.thresholds
	batch.setup(
		batch_id,
		category,
		channel,
		source_id,
		target_ids,
		source_event,
		t,
		real_open,
		real_grace,
		resolver,
		thresholds
		)
	_connect_batch_signals(batch)
	active_batches[batch_id] = batch
	batch_created.emit(batch_id)
	#if EventBus:
	#	EventBus.conflict_batch_created.emit(batch_id, category, channel)
	return batch

func submit_input(batch_id: String, payload: Dictionary, now: float = -1.0) -> bool:
	if not active_batches.has(batch_id):
		return false
	var t := current_time if now < 0.0 else now
	return active_batches[batch_id].add_input(payload, t)

func process(now: float) -> void:
	current_time = now
	var to_remove: Array[String] = []
	for batch_id in active_batches.keys():
		var batch := active_batches[batch_id]
		batch.update(now)
		if batch.phase == ConflictBatch.BatchPhase.RESOLVED:
			if batch.result == null:
				resolver_missing.emit(batch.category, batch.channel, batch.batch_id)
				#if EventBus:
				#	EventBus.conflict_resolver_missing.emit(batch.category, batch.channel, batch.batch_id)
			batch_resolved.emit(batch.batch_id, batch.result)
			#if EventBus:
			#	EventBus.conflict_batch_resolved.emit(batch.batch_id, batch.category, batch.channel, batch.result)
			to_remove.append(batch_id)
	for batch_id in to_remove:
		active_batches.erase(batch_id)
		batch_removed.emit(batch_id)

func force_resolve(batch_id: String, now: float = -1.0) -> Variant:
	if not active_batches.has(batch_id):
		return null
	var t := current_time if now < 0.0 else now
	var batch := active_batches[batch_id]
	var result : Variant = batch.lock_and_resolve(t)
	batch_resolved.emit(batch.batch_id, result)
	#if EventBus:
	#	EventBus.conflict_batch_resolved.emit(batch.batch_id, batch.category, batch.channel, result)
	active_batches.erase(batch_id)
	batch_removed.emit(batch_id)
	return result

func clear() -> void:
	active_batches.clear()

func has_batch(batch_id: String) -> bool:
	return active_batches.has(batch_id)

func get_batch(batch_id: String) -> ConflictBatch:
	return active_batches.get(batch_id, null)

func _on_tick() -> void:
	process(current_time + _timer.wait_time)

func _connect_batch_signals(batch: ConflictBatch) -> void:
	if batch == null:
		return
	if not batch.batch_opened.is_connected(_on_batch_opened):
		batch.batch_opened.connect(_on_batch_opened)
	if not batch.batch_locked.is_connected(_on_batch_locked):
		batch.batch_locked.connect(_on_batch_locked)
	if not batch.batch_resolved.is_connected(_on_batch_resolved):
		batch.batch_resolved.connect(_on_batch_resolved)

func _on_batch_opened(batch_id: String) -> void:
	#EventBus.conflict_batch_created.emit(batch_id)
	pass

func _on_batch_locked(batch_id: String) -> void:
	#EventBus.conflict_batch_locked.emit(batch_id)
	pass

func _on_batch_resolved(batch_id: String, result: Variant) -> void:
	#EventBus.conflict_batch_resolved.emit(batch_id, result)
	pass

func _make_registry_key(category: String, channel: String) -> String:
	return "%s:%s" % [category, channel]

func _make_batch_id(category: String, channel: String, source_id: String, now: float) -> String:
	return "%s:%s:%s:%s" % [category, channel, source_id, str(now)]
