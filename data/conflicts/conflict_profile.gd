extends Resource
class_name ConflictProfile

@export var open_duration: float = 0.10
@export var grace_duration: float = 0.03

## Defines the assessment thresholds for the conflict.
## Each ResponseType maps to an Array of one or two float values:
## - 1 value: direct upper threshold [max]
## - 2 values: threshold span [min, max]
## Threshold span must not overlap.
@export var thresholds: Dictionary[ConflictBatch.ResponseType,PackedFloat32Array]
