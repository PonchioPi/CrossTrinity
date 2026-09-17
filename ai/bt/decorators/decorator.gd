class_name BTDecorator
extends BTTask

func set_branches(value:Array) -> void:
    branches = value
    if branches.size() != 1:
        push_error("Behavior Tree error: %s must have only one child (%s)"%[cache_key, tree.cache_key])
        return
    branches[0].rank = rank + 1
    branches[0].set_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = ((status & (~0b11)) | branches[0]._tick(actor, blackboard))

func reset(blackboard:BlackBoard) -> void:
    pass
