extends UtilityEvaluator
class_name UtilityConsideration

@export var consideration_curve: Curve

@export var max_considered_value: int:
    set = set_max_consideration

@export var considered_value: int:
    set = set_consideration

func set_max_consideration(value: int) -> void:
    max_considered_value = value

func set_consideration(value: int) -> void:
    considered_value = value

func calculate_raw_score() -> float:
    return float(considered_value)/float(max_considered_value)

func apply_score(score: float) -> float:
    return consideration_curve.sample_baked(score)

func evaluate_score() -> float:
    var considered_result: float = calculate_raw_score()
    set_score(considered_result * apply_score(considered_result))
    return score

func set_max_consideration(value: int) -> void:
    max_considered_value = value

func set_consideration(value: int) -> void:
    considered_value = value
