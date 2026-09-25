extends UtilityEvaluator
class_name UtilityAction

signal  action_finished

@export var aggregator: UtilityAggregator:
    set = set_aggregator

func set_aggregator(value: UtilityAggregator) -> void:
    aggregator = value

func act() -> void:
    pass

func tick(actor: Node, blackboard: BlackBoard) -> void:
    emit_signal(&"action_finished")

func finish() -> void:
    pass

func evaluate_score() -> float:
    return aggregator.evaluate_score()
