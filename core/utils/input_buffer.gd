extends Node

var Sequences = {
	
}

var Axis_couples = {
	"LeftController":[JOY_ANALOG_LX,JOY_ANALOG_LY],
	"RightController":[JOY_ANALOG_RX,JOY_ANALOG_RY],
	"ControllerLeft":[JOY_AXIS_0,JOY_AXIS_1],
	"ControllerRight":[JOY_AXIS_2,JOY_AXIS_3]
}

export var memory_window: int = 1500
export var hold_check: int = 68
export var max_input_memory: int = 32

var buffer: Array
var held_buffer: Array 
var reference_vect: Vector2 setget set_refvect

var timestamp: int

var input_timestamps:= {}

func set_refvect(value:Vector2) -> void:
	reference_vect = value

func _process(delta:float) -> void:
	var current_time: int = Time.get_ticks_msec()
	if buffer.size():
		for time in input_timestamps.keys():
			if current_time - time < memory_window:
				continue
			else:
				var remove_key = input_timestamps[time]
				input_timestamps.erase(time)
				buffer.erase(remove_key)

func _unhandled_input(event:InputEvent) -> void:
	timestamp = Time.get_ticks_msec()
	check_buffer()
	if event is InputEventAction:
		_unhandled_action(event)
	if event is InputEventMouseButton:
		_unhandled_m_button(event)
	if event is InputEventMouseMotion:
		_unhandled_m_motion(event)
	if event is InputEventJoypadButton:
		_unhandled_joy_button(event)
	if event is InputEventJoypadMotion:
		_unhandled_joy_motion(event)
	if event is InputEventMouseMotion:
		_unhandled_m_motion(event)
	if event is InputEventMouseButton:
		_unhandled_m_button(event)
	if event is InputEventScreenDrag:
		_unhandled_scrn_drag(event)
	if event is InputEventScreenTouch:
		_unhandled_scrn_touch(event)
	interpret_sequence(buffer)

func _unhandled_action(event:InputEventAction) -> void:
	var input_action: String = event.get_action()
	if !event.is_pressed() or event.get_strength()\
	< InputMap.action_get_deadzone(input_action):
		if input_action in held_buffer:
			held_buffer.erase(input_action)
			return
		else:
			if input_action in input_timestamps.values():
				if !input_action in held_buffer:
					held_buffer.push_back(input_action)
					return
			if !input_action in held_buffer:
				input_timestamps[timestamp] = input_action
				buffer.push_back(input_action)

func _unhandled_m_button(event:InputEventMouseButton) -> void:
	var input_index: int = event.get_button_index()
	if !event.is_pressed():
		if input_index in held_buffer:
			held_buffer.erase(input_index)
		return
	else:
		if input_index in input_timestamps.values():
			if !input_index in held_buffer:
				held_buffer.append(input_index)
			return
		if !input_index in held_buffer:
			input_timestamps[timestamp] = input_index
			buffer.append(input_index)

func _unhandled_m_motion(event:InputEventMouseMotion) -> void:
	var motion_input: Vector2 = handle_vect(event.get_relative())
	if motion_input == Vector2.ZERO:
		if reference_vect in held_buffer:
			held_buffer.erase(reference_vect)
		set_refvect(Vector2.ZERO)
		return
	else:
		if motion_input == reference_vect and reference_vect in input_timestamps.values():
			if !reference_vect in held_buffer:
				held_buffer.append(reference_vect)
			return
		if motion_input != reference_vect and !motion_input in held_buffer:
			set_refvect(motion_input)
			input_timestamps[timestamp] = motion_input
			buffer.push_back(motion_input)

func _unhandled_joy_button(event:InputEventJoypadButton) -> void:
	var input_index: int = event.get_button_index()
	if !event.is_pressed():
		if input_index in held_buffer:
			held_buffer.erase(input_index)
		return
	else:
		if input_index in input_timestamps.values():
			if !input_index in held_buffer:
				held_buffer.append(input_index)
			return
		if !input_index in held_buffer:
			input_timestamps[timestamp] = input_index
			buffer.append(input_index)

func _unhandled_joy_motion(event:InputEventJoypadMotion) -> void:
	var input_vector:= Vector2.ZERO
	var input_axis: int = event.get_axis()
	var input_value: float = event.get_axis_value()
	if abs(input_value) <= 0.2: #0.2 is Godot Engine's joypad motion deadzone
		return
	if input_timestamps.has(timestamp):
		input_vector = input_timestamps[timestamp]
	for inputs in Axis_couples.values():
		if input_value == inputs[0]:
			input_vector.x = event.get_axis_value()
			break
		else:
			input_vector.y -= event.get_axis_value()
			break
	input_vector = handle_vect(input_vector)
	if input_vector == Vector2.ZERO:
		if input_vector in held_buffer:
			held_buffer.erase(input_vector)
		return
	else:
		if input_vector in input_timestamps.values():
			if !input_vector in held_buffer:
				held_buffer.append(input_vector)
			return
		if !input_vector in held_buffer:
			input_timestamps[timestamp] = handle_vect(input_vector)
			buffer.append(input_vector)

func _unhandled_scrn_drag(event:InputEventScreenDrag) -> void:
	if event.get_index() == 1:
		var drag_input: Vector2= handle_vect(event.get_relative())
		if drag_input == Vector2.ZERO:
			if reference_vect in held_buffer:
				held_buffer.erase(reference_vect)
			set_refvect(Vector2.ZERO)
			return
		else:
			if drag_input == reference_vect and reference_vect in input_timestamps.values():
				if !reference_vect in held_buffer:
					held_buffer.append(reference_vect)
				return
			if drag_input != reference_vect and !drag_input in held_buffer:
				set_refvect(drag_input)
				input_timestamps[timestamp] = drag_input
				buffer.push_back(drag_input)

func _unhandled_scrn_touch(event:InputEventScreenTouch) -> void:
	var indexed_input: Dictionary = {event.get_index():event.get_position()}
	if !event.is_pressed() or event.is_canceled():
		return
	if !input_timestamps.has(timestamp):
		input_timestamps[timestamp] = []
		buffer.push_back([])
	var index: int = buffer.rfind(input_timestamps[timestamp])
	input_timestamps[timestamp].push_back(indexed_input)
	buffer[index].push_back(indexed_input)

func _unhandled_key_input(event:InputEventKey) -> void:
	var timestamp: int = Time.get_ticks_msec()
	check_buffer()
	var key_code: int = event.get_scancode()
	if !event.is_pressed():
		if key_code in held_buffer:
			held_buffer.erase(key_code)
			return
	else:
		if key_code in input_timestamps.values()\
		and timestamp - input_timestamps.find_key(key_code) < hold_check:
			if !key_code in held_buffer:
				held_buffer.append(key_code)
				return
		if !key_code in held_buffer:
			input_timestamps[timestamp] = key_code
			buffer.append(key_code)
	interpret_sequence(buffer)

func check_buffer() -> void:
	if buffer.size() == max_input_memory:
		var to_delete = buffer.pop_front()
		input_timestamps.erase(input_timestamps.find_key(to_delete))

func handle_vect(vect:Vector2) -> Vector2:
	var norm_vect = vect.normalized()
	if norm_vect.dot(Vector2.RIGHT) >= 0 and norm_vect.dot(Vector2.RIGHT) > 0.924:
		return Vector2.RIGHT
	elif norm_vect.dot(Vector2.LEFT) >= 0 and norm_vect.dot(Vector2.LEFT) > 0.924:
		return Vector2.LEFT
	elif norm_vect.dot(Vector2.UP) >= 0 and norm_vect.dot(Vector2.UP) > 0.924:
		return Vector2.UP
	elif norm_vect.dot(Vector2.DOWN) >= 0 and norm_vect.dot(Vector2.DOWN) > 0.924:
		return Vector2.DOWN
	elif norm_vect.dot(Vector2(1,1)) >= 0 and norm_vect.dot(Vector2(1,1)) >= 0.924:
		return Vector2(1,1)
	elif norm_vect.dot(Vector2(-1,1)) >= 0 and norm_vect.dot(Vector2(-1,1)) >= 0.924:
		return Vector2(-1,1)
	elif norm_vect.dot(Vector2(1,-1)) >= 0 and norm_vect.dot(Vector2(1,-1)) >= 0.924:
		return Vector2(1,-1)
	elif norm_vect.dot(Vector2(-1,-1)) >= 0 and norm_vect.dot(Vector2(-1,-1)) >= 0.924:
		return Vector2(-1,-1)
	return Vector2.ZERO

func interpret_sequence(sequence:Array) -> void:
	for input in sequence:
		var index: int = sequence.find(input)
		for key_seq in Sequences.values():
			if input == key_seq[0]:
				var sub_seq: Array = sequence.slice(index,index+key_seq.size()-1,1,true)
				if sub_seq == key_seq:
					print(Sequences.find_key(key_seq))
					for selec in key_seq:
						input_timestamps.erase(input_timestamps.find_key(selec))
						sequence.erase(selec)
					print(sequence)
					return
				else:
					continue
			else:
				continue
	print("nosquencefound.")
