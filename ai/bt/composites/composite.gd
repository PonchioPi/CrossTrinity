class_name BTComposite
extends BTTask

@export var random:bool = false:
    set = set_random

var random_children

func set_branches(value:Array[BTTask]) -> void:
    branches = value
    if branches.size() < 1:
        push_error("Behavior Tree error: %s should have at least one child (Tree %s)"%[cache_key, tree.cache_key])
        return
    for branch in branches:
        branch.rank = rank + 1
        branch.set_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)

func set_random(value:bool) -> void:
    random = value
    status = (int(value) << 3 | (status & 0b111))

func is_random() -> bool:
    return status >> 3 == 1
