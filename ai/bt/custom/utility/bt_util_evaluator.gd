class_name BTUtilEvaluator
extends BTTask

var scores: PackedFloat32Array

var score:float :
    set = set_score,
    get = get_score

func set_score(value:float) -> void:
    score = value

func get_score() -> float:
    return score

func evaluate_score() -> float:
    return 0.0
