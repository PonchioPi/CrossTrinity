extends RefCounted
class_name EventHeap

var _data: Array[EventData]

func is_empty() -> bool:
	return _data.is_empty()

func size() -> int:
	return _data.size()

func clear() -> void:
	_data.clear()

func peek() -> EventData:
	if _data.is_empty():
		return null
	return _data[0]

func push(item: EventData) -> void:
	_data.append(item)
	_sift_up(_data.size() - 1)

func pop() -> EventData:
	if _data.is_empty():
		return null
	var root := _data[0]
	var last :EventData = _data.pop_back()
	if not _data.is_empty():
		_data[0] = last
		_sift_down(0)
	return root

func _sift_up(index: int) -> void:
	while index > 0:
		var parent := (index - 1) >> 1
		if not _less(_data[index], _data[parent]):
			break
		_swap(index, parent)
		index = parent

func _sift_down(index:int) -> void:
	var size := _data.size()
	while true:
		var left := (index << 1) + 1
		var right := left + 1
		var best := index
		if left < size and _less(_data[left], _data[best]):
			best = left
		if right < size and _less(_data[right], _data[best]):
			best = right
		if best == index:
			break
		_swap(index, best)
		index = best

func _less(a: EventData, b: EventData) -> bool:
	if a.execute_at != b.execute_at:
		return a.execute_at < b.execute_at
	if a.priority != b.priority:
		return a.priority > b.priority
	return a.sequence < b.sequence

func _swap(i:int, j:int) -> void:
	var tmp := _data[i]
	_data[i] = _data[j]
	_data[j] = tmp

func peek_until(dead_line:float) -> Array[EventData]:
	var queue: Array[EventData] = []
	var copy:= EventHeap.new()
	copy._data = _data.duplicate()
	while not copy.is_empty():
		var event := copy.peek()
		if event.execute_at > dead_line:
			break
		queue.append(copy.pop())
	return queue
