extends Resource
class_name UtilityEvaluator

signal selection_mode_changed(new_mode)

@export var enabled: bool = false:
    set = set_enabled,
    get = is_enabled

var scores: Array

var score: float:
    set = set_score,
    get = get_score

func set_enabled(value: bool) -> void:
    ennabled = value

func set_score(value: float) -> void:
    score = value

func is_enabled() -> bool:
    return enabled

func get_score() -> float:
    return score

func evaluate_score() -> float:
    return 0.0
