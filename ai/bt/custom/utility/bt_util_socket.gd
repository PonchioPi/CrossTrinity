class_name BTUtilSocket
extends BTUtilEvaluator

enum AggregationMode {
    MIN,
    MAX,
    AVERAGE,
    SUM,
    PRODUCT
}

@export var aggregation_mode: AggregationMode = AggregationMode.MAX:
    set = set_aggregation_mode

@export var considerations: Array[UtilityConsideration]

func set_aggregation_mode(value: AggregationMode) -> void:
    aggregation_mode = value

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
            set_score(min(scores))
        AggregationMode.MAX:
            set_score(max(scores))
        AggregationMode.AVERAGE:
            set_score(average(scores))
        AggregationMode.SUM:
            set_score(sum(scores))
        AggregationMode.PRODUCT:
            set_score(product(scores))
    return score

func sum(array: Array) -> float:
    var result:= .0
    for value in array:
        result += value
    return result

func average(array: Array) -> float:
    var result:= sum(array)
    return result/array.size()

func product(array: Array) -> float:
    var result:= 1.0
    for value in array:
        result *= value
        if not result:
            break
    return result

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = ((status & (~0b11)) | branches[0]._tick(actor, blackboard))

func _init() -> void:
    cache_key = "UtilitySocket#%s"%[self.get_instance_id()]

func set_branches(value:Array) -> void:
    branches = value
    if branches.size() != 1:
        push_error("Behavior Tree error: %s should have exactly one child (%s)" % [cache_key, tree.cache_key])
        return
    branches[0].rank = rank + 1
    branches[0].set_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)
