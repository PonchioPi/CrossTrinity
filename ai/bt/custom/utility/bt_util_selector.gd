class_name BTUtilEvaluator
extends BTUtilSelector

enum SelectionMode {
    MAX,
    ROULETTE
}

@export var selection_mode: SelectionMode = SelectionMode.MAX

var current_branch: BTUtilSocket

func set_selection_mode(value: SelectionMode) -> void:
    selection_mode = value

func gather_scores() -> void:
    for i in range(branches.size()):
        scores[i] = branches[i].evaluate_score()

func evaluate_actions() -> BTUtilSocket:
    gather_scores()
    match selection_mode:
        SelectionMode.MAX:
            score = max(scores)
        SelectionMode.ROULETTE:
            var random_scores := choose_best_scores(scores)
            random_scores.shuffle()
            score = random_scores[randi_range(0, random_scores.size()-1)]
    return branches[scores.find(score)]

func choose_best_scores(array: PackedFloat32Array) -> Array[float]:
    array.sort()
    var limit := array.size() >> 1
    var new_array := Array(array.slice(limit))
    return new_array

func tick(actor:Node, blackboard:BlackBoard) -> void:
    blackboard._set_("next_action", evaluate_actions(), cache_key)
    status = ((status & (~0b11)) | current_branch._tick(actor, blackboard))
    if is_standby():
        blackboard._set_("previous_action", current_branch, cache_key)
        var new_branch:BTUtilSocket = blackboard._get_("next_action", branches[0], cache_key)
        current_branch = new_branch
        blackboard._set_("current_action", new_branch, cache_key)
    return

func _init() -> void:
    cache_key = "UtilitySelector_%s"%[self.get_instance_id()]

func set_branches(value:Array[BTTask]) -> void:
    branches = value
    if branches.size() < 1:
        push_error("Behavior Tree error: %s should have at least one child (Tree: %s)"%[self.cache_key, tree.cache_key])
        return
    for branch in branches:
        if not branch is BTUtilSocket:
            push_error("Behavior Tree error: %s should have only BTUtilSockets as its children (Tree: %s)"\
            % [self.cache_key, tree.cache_key])
            return
        branch.rank = rank + 1
        branch.set_tree(tree)
    current_branch = value[0]
    branches_changed.emit(self.get_instance_id(), branches)
            
