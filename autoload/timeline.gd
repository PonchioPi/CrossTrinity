extends Node

signal timeline_event(event: EventData)
signal timeline_tick(current_time: float)
signal timeline_empty

const CONSUMERS: Array[String] = [
	
]

@export var tick_interval: float = 0.05
@export var auto_process: bool = true

var current_time: float = .0
var _heap: EventHeap = EventHeap.new()
var _consumers: Array[GDScript]
var _timer: Timer
var _sequence_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = tick_interval
	_timer.autostart = auto_process
	add_child(_timer)
	_timer.timeout.connect(_on_tick)
	if CONSUMERS:
		for consumer_script in CONSUMERS:
			var consumer: GDScript = load(consumer_script)
			_consumers.append(consumer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not auto_process:
		advance_time(delta)

func advance_time(delta:float) -> void:
	current_time += delta
	timeline_tick.emit(current_time)
	_process_due_events()

func _process_due_events() -> void:
	while not _heap.is_empty():
		var event := _heap.peek()
		if event.execute_at > current_time:
			break
		event = _heap.pop()
		timeline_event.emit(event)
		#if EventBus:
		#	EventBus.timeline_event_processed.emit(event)
		_dispatch_event(event)
	if _heap.is_empty():
		timeline_empty.emit()
		#if EventBus:
		#	EventBus.timeline_emptied.emit()

func _dispatch_event(event: EventData) -> void:
	#if EventBus:
	#	EventBus.timeline_event_dispatched.emit(event)
	for consumer in _consumers:
		if consumer != null and consumer.handles_event_type(event.event_type):
			consumer.handle_event(event)

func schedule_event(event: EventData) -> void:
	if event == null:
		return
	event.queued_at = current_time
	if event.delay < 0.0:
		event.delay = 0.0
	event.execute_at = current_time + event.delay
	event.sequence = _sequence_counter
	_sequence_counter += 1
	_heap.push(event)
	#if EventBus:
	#	EventBus.timeline_event_scheduled.emit(event)

func schedule_events(events: Array[EventData]) -> void:
	for event in events:
		schedule_event(event)

func _on_tick() -> void:
	advance_time(tick_interval)

func clear() -> void:
	_heap.clear()
	timeline_empty.emit()
	#if EventBus:
	#	EventBus.timeline_emptied.emit()

func size() -> int:
	return _heap.size()

func is_empty() -> bool:
	return _heap.is_empty()

func peek() -> EventData:
	if is_empty():
		return null
	return _heap.peek()

func peek_ahead(offset:float) -> Array[EventData]:
	var deadline:= current_time + offset
	return _heap.peek_until(deadline)
