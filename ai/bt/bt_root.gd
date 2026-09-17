class_name BTRoot
extends BTTask

func _init() -> void:
    cache_key = "Root#%s"%[self.get_instance_id()]

func set_branches(value:Array[BTTask]) -> void:
    branches = value
    if branches.size() != 1:
        push_error("Behavior Tree error: %s should have only one child (Tree: %s)"%[cache_key, tree.name])
        return
    branches[0].rank = rank + 1
    branches[0].set_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)

func tick(actor:Node, blackboard:Blackboard) -> void:
    status = ((status & (~0b11)) | branches[0]._tick(actor, blackboard))
