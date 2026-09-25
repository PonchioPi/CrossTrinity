extends UtilityEvaluator
class_name UtilityAggregator

enum AggregationMode {
    MIN,
    MAX,
    AVERAGE,
    SUM,
    PRODUCT
}

@export var aggregation_mode: AggregationMode = AggregationMode.MIN:
    set = set_aggregation_mode

@export var considerations: Array[UtilityConsideration]

func set_aggregation_mode(value: AggregationMode) -> void:
    aggregation_mode = value
    selection_mode_changed.emit(value)

func set_considerations(value: Array[UtilityConsideration]) -> void:
    considerations = value
    scores.resize(considerations.size())

func gather_scores() -> void:
    for i in range(considerations.size()):
        scores[i] = considerations[i].evaluate_score()

func evaluate_score() -> float:
    gather_scores()
    match aggregation_mode:
        AggregationMode.MIN:
            set_score(scores.min())
        AggregationMode.MAX:
            set_score(scores.max())
        AggregationMode.AVERAGE:
            set_score(average(scores))
        AggregationMode.SUM:
            set_score(sum(scores))
        AggregationMode.PRODUCT:
            set_score(product(scores))
    return score

func sum(array: Array) -> float:
    var result := .0
    for value in array:
        result += value
    return result

func average(array: Array) -> float:
    var result := sum(array)
    return result/array.size()

func product(array: Array) -> float:
    var result := 1.0
    for value in array:
        result *= value
        if not result:
            break
    return result
