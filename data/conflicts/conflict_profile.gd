extends Resource
class_name ConflictProfile

@export var category: StringName
@export var channel: StringName
@export var priority: int = 0

@export var open_duration: float = 0.10
@export var grace_duration: float = 0.03

@export var limited_inputs: bool = false
@export var input_threshold: int = 1

@export var trigger_direct_input: bool = false
@export var trigger_threshold: int = 1
@export var trigger_event_id: String = ""

## Defines the assessment thresholds for the conflict.
## Each ResponseType maps to an Array of one or two float values:
## - 1 value: direct upper threshold [max] [br]
## - 2 values: threshold span [min, max] [br]
## Threshold span must not overlap.
@export var thresholds: Dictionary[ConflictBatch.ResponseType,PackedFloat32Array]
